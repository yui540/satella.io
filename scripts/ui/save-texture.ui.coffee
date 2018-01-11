class SaveTexture
	constructor: (app) ->
		@app = app
		@ctx = @app.getContext '2d'

		@width   = 0
		@height  = 0
		@pos     = { x: 0, y: 0 }
		@size    = 0
		@list    = [2, 4, 8, 16 ,32, 64, 128 ,256, 512, 1024, 2048]

		@listeners = {}
	
	##
	# イベントリスナの追加
	# @param event:    イベント名
	# @param listener: コールバック関数 
	##
	on: (event, listener) ->
		if @listeners[event] is undefined
			@listeners[event] = []

		@listeners[event].push listener

	##
	# イベントの発火
	# @param event: イベント名
	# @param data:  データ
	##
	emit: (event, data) ->
		listener = @listeners[event]

		if listener is undefined
			return;

		for callback in listener
			callback data

	##
	# テクスチャの生成
	# @param file: ファイル
	##
	create: (file) ->
		# 画像以外を弾く
		if not @check file.type
			@emit 'error', '選択されたファイルは画像ではありません'
			return

		@readFile file

	##
	# 画像かチェック
	# @param type: タイプ
	##
	check: (type) ->
		if type is 'image/png' or
		   type is 'image/jpg' or
		   type is 'image/jpeg' or
		   type is 'image/gif'
		    return true
		else
			return false

	##
	# ファイルの読み込み
	# @param file: ファイル
	##
	readFile: (file) ->
		fr = new FileReader()
		fr.readAsDataURL file
		fr.onload = (e) =>
			datauri = fr.result
			@loadImage datauri

	##
	# 画像の読み込み
	# @param datauri: データURI
	##
	loadImage: (datauri) ->
		img = new Image()
		img.src = datauri
		img.onload = (e) =>
			@rectSize img.width, img.height
			@writeCanvas img

	##
	# 比率の調整
	# @param width:  幅
	# @param height: 高さ
	##
	rectSize: (width, height) ->
		if width > height # 縦長
			size    = @axisSize width
			per     = size / width
			@size   = size
			@width  = width * per
			@height = height * per
			@pos.x  = 0
			@pos.y  = (@width - @height) / 2
		else              # 横長
			size    = @axisSize height
			per     = size / height
			@size   = size
			@width  = width * per
			@height = height * per
			@pos.x  = (@height - @width) / 2
			@pos.y  = 0

	##
	# キャンバスへ書き込む
	# @param img: 画像オブジェクト
	##
	writeCanvas: (img) ->
		@app.width  = @size
		@app.height = @size
		@ctx.clearRect 0, 0, @size, @size
		@ctx.drawImage img, @pos.x, @pos.y, @width, @height

		@emit 'create', @app.toDataURL()

	##
	# 基準サイズの取得
	# @param size: サイズ
	##
	axisSize: (size) ->
		tmp = []
		min = null

		for i in [0..@list.length - 1]
			tmp[i] = [Math.abs(@list[i] - size), i]

		min = tmp[0]

		for i in [1..tmp.length - 1]
			if min[0] > tmp[i][0]
				min = tmp[i]

		return @list[min[1]]

	##
	# 切り取ったテクスチャの生成
	# @param params: data & pos & size
	##
	recreate: (params) ->
		img = new Image()
		img.src = params.data
		img.onload = (e) =>
			s = img.width * params.size
			x = img.width * params.pos.x
			y = img.height * params.pos.y
			@app.width  = s
			@app.height = s
			@ctx.drawImage img, -x, -y, img.width, img.height

			origin = @app.toDataURL()

			r_img = new Image()
			r_img.src = origin
			r_img.onload = (e) =>
				r_s = @axisSize r_img.width
				@app.width  = r_s
				@app.height = r_s
				@ctx.clearRect 0, 0, r_s, r_s
				@ctx.drawImage r_img, 0, 0, r_s, r_s

				@emit 'recreate', @app.toDataURL()

module.exports = SaveTexture