class ImageView
	constructor: (app) ->
		@app = app

		@size = 300
		@pos  = { x: 0, y: 0 }

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
	# 描画
	# @param data: データURI
	##
	render: (data) ->
		@data = data
		style = @createStyle()
		app   = @createElement style
		@app.innerHTML = app

		# image_view
		@image_view = @app.children[0]

		# title_bar
		@title_bar = @image_view.children[0]
		@close_btn = @title_bar.children[0]

		# input
		@layer_name = @image_view.children[1]
		@layer_mesh = @image_view.children[2]

		# preview
		@image_preview = @image_view.children[3]
		@preview_area  = @image_preview.children[0]
		@scale_btn     = @preview_area.children[0]

		# param_box
		@param_li = @image_view.children[4]
		@add_btn  = @image_view.children[5]

		@bindEvent() # イベントの紐付け

	##
	# スタイルシートの生成
	##
	createStyle: ->
		width  = window.innerWidth
		height = window.innerHeight
		style = "
			.image-view {
				position: fixed;
				top: #{ height / 2 - 191.5 }px; 
				left: #{ width / 2 - 255 }px;
				width: 550px; height: 383px;
				border-radius: 5px;
				box-sizing: border-box;
				background-color: #4c4c4c;
				border: solid 1px #222;
				z-index: 20;
			}
			.image-view:after {
				content: \"\"; display: block; clear: both;
			}
			.image-view .title-bar {
				position: relative;
			    width: 100%; height: 20px;
			    border-bottom: solid 1px #222; font-size: 12px;
			    line-height: 20px; text-align: center;
			    color: #999; background-color: #333;
			    border-top-left-radius: 5px;
			    border-top-right-radius: 5px;
			    box-sizing: border-box;
			}
			.image-view .close-btn {
				position: absolute;
				width: 20px; height: 20px;
				cursor: pointer;
			}
			.image-view .close-btn:before,
			.image-view .close-btn:after {
				position: absolute;
				top: 9.0px; left: 2.5px;
				content: \"\"; display: block;
				width: 15px; height: 1px;
				background-color: #ccc;
			}
			.image-view .close-btn:before { transform: rotate(45deg); }
			.image-view .close-btn:after { transform: rotate(-45deg); }
			.image-view input {
				float: left;
				font-size: 10px; color: #ccc;
				padding: 10px; box-sizing: border-box;	
				background-color: #393939;
				margin-left: 10px; margin-top: 10px;
			}
			.image-view input:focus { outline: none; }
			.image-view .layer-name {
				width: 400px; height: 30px;
			}
			.image-view .layer-mesh {
				width: 120px; height: 30px;
			}
			.image-view .image-preview {
				float: left;
				position: relative;
				width: 300px; height: 300px;
				background-color: #333;
				background-image: url(#{ @data });
				background-size: contain;
				background-position: center;
				margin-top: 10px; margin-left: 11px;
			}
			.image-view .image-preview .preview-area {
				position: absolute; 
				top: #{ @pos.y }px; left: #{ @pos.x }px;
				width: #{ @size }px; height: #{ @size }px; 
				box-sizing: border-box; 
				border: solid 1px #595DEF;
				box-shadow: 0 0 10px #4c4c4c;
			}
			.image-view .image-preview .preview-area .scale-btn {
				position: absolute;
				width: 10px; height: 10px;
				background-color: #595DEF;
				bottom: 0; right: 0;
				cursor: pointer;
			}
			.image-view .param-box {
				float: right;
				width: 210px; height: 300px;
				margin-top: 10px; margin-right: 10px;
			}
			.image-view .param-box .param-li {
				position: relative;
				width: 210px; height: 30px;
				background-color: #393939;
				margin-bottom: 1px;
			}
			.image-view .param-box .param-li .param-li-check {
				position: absolute;
				top: 5px; left: 5px;
				width: 20px; height: 20px;
				background-color: #111;
				border-radius: 3px;
				cursor: pointer;
			}
			.image-view .param-box .param-li .param-li-check[data-state=\"active\"] {
				background-image: url(../img/assets/check.png);
				background-size: 70%;
				background-position: center;
				background-repeat: no-repeat;
			}
			.image-view .param-box .param-li .param-li-name {
				position: absolute;
				top: 5px; right: 5px;
				width: 175px; height: 20px;
				background-color: #222;
				font-size: 10px; color: #999;
				line-height: 20px; box-sizing: border-box;
				padding: 0 5px;
			}
			.image-view .add-btn {
				position: absolute;
				bottom: 10px; right: 10px;
				width: 100px; height: 25px;
				font-size: 12px; color: #fff;
				line-height: 25px; text-align: center;
				cursor: pointer;
				background-color: #595DEF;
				border-radius: 3px;
			}
		".replace(/(\t|\n)/g, '')

		return style

	##
	# 要素の生成
	##
	createElement: (style) ->
		app = "
			<div class=\"image-view\">
				<div class=\"title-bar\">
					<div class=\"close-btn\"></div>
				</div>
				<input type=\"text\" class=\"layer-name\" 
					maxlength=\"20\" 
					placeholder=\"layer_name（20char）\" />
				<input type=\"text\" class=\"layer-mesh\" 
					placeholder=\"mesh（1〜30）\" />
				<div class=\"image-preview\">
					<div class=\"preview-area\">
						<div class=\"scale-btn\"></div>
					</div>
				</div>
				<div class=\"param-box\">
					<div class=\"param-li\">
						<div class=\"param-li-check\" data-val=\"NEAREST\" data-state=\"\"></div>
						<div class=\"param-li-name\">NEAREST</div>
					</div>
					<div class=\"param-li\">
						<div class=\"param-li-check\" data-val=\"LINEAR\" data-state=\"\"></div>
						<div class=\"param-li-name\">LINEAR</div>
					</div>
					<div class=\"param-li\">
						<div class=\"param-li-check\" data-val=\"NEAREST_MIPMAP_NEAREST\" data-state=\"\"></div>
						<div class=\"param-li-name\">NEAREST_MIPMAP_NEAREST</div>
					</div>
					<div class=\"param-li\">
						<div class=\"param-li-check\" data-val=\"NEAREST_MIPMAP_LINEAR\" data-state=\"\"></div>
						<div class=\"param-li-name\">NEAREST_MIPMAP_LINEAR</div>
					</div>
					<div class=\"param-li\">
						<div class=\"param-li-check\" data-val=\"LINEAR_MIPMAP_NEAREST\" data-state=\"\"></div>
						<div class=\"param-li-name\">LINEAR_MIPMAP_NEAREST</div>
					</div>
					<div class=\"param-li\">
						<div class=\"param-li-check\" data-val=\"LINEAR_MIPMAP_LINEAR\" data-state=\"active\"></div>
						<div class=\"param-li-name\">LINEAR_MIPMAP_LINEAR</div>
					</div>
				</div>
				<div class=\"add-btn\">add</div>
			</div>
			<style>#{ style }</style>"

		return app

	##
	# イベントの紐付け
	##
	bindEvent: ->
		@eventClose()   # 閉じる
		@eventWindow()  # ウィンドウ移動
		@eventPreview() # プレビュー
		@eventScale()   # 拡大縮小
		@eventCheck()   # チェックボタン
		@eventAdd()     # 追加ボタン

	##
	# 閉じるのイベント
	##
	eventClose: ->
		@close_btn.addEventListener 'click', (e) =>
			@delete()

	##
	# ウィンドウ移動のイベント
	##
	eventWindow: ->
		down = false

		# mousedown -----------------------------------
		@title_bar.addEventListener 'mousedown', (e) =>
			rect = @title_bar.getBoundingClientRect()
			down = {
				x: e.clientX - rect.left
				y: e.clientY - rect.top
			}

		# mousemove -----------------------------------
		window.addEventListener 'mousemove', (e) =>
			if down is false
				return

			x = e.clientX - down.x
			y = e.clientY - down.y

			if y < 20
				y = 20

			@image_view.style.top  = y + 'px'
			@image_view.style.left = x + 'px'

		# mouseup -------------------------------------
		window.addEventListener 'mouseup', (e) =>
			down = false

	##
	# プレビューのイベント
	##
	eventPreview: ->
		down = false

		# mousedown -----------------------------------
		@preview_area.addEventListener 'mousedown', (e) =>
			rect = @preview_area.getBoundingClientRect()
			down = {
				x: e.clientX - rect.left
				y: e.clientY - rect.top
			}

			if down.x > @size - 10 or down.y > @size - 10
				down = false

		# mousemove -----------------------------------
		window.addEventListener 'mousemove', (e) =>
			if down is false
				return

			rect = @image_preview.getBoundingClientRect()
			x    = e.clientX - rect.left - down.x
			y    = e.clientY - rect.top - down.y

			if x < 0 # x
				x = 0
			else if x > 300 - @size
				x = 300 - @size

			if y < 0 # y
				y = 0
			else if y > 300 - @size
				y = 300 - @size

			@pos.x = x
			@pos.y = y
			@preview_area.style.left = @pos.x + 'px';
			@preview_area.style.top  = @pos.y + 'px';

		# mouseup -------------------------------------
		window.addEventListener 'mouseup', (e) =>
			down = false

	##
	# 拡大縮小のイベント
	##
	eventScale: ->
		down = false

		# mousedown -----------------------------------
		@scale_btn.addEventListener 'mousedown', (e) =>
			rect = @image_preview.getBoundingClientRect()
			down = {
				x: e.clientX - rect.left
				y: e.clientY - rect.top
			}

		# mousemove -----------------------------------
		window.addEventListener 'mousemove', (e) =>
			if down is false
				return

			rect   = @image_preview.getBoundingClientRect()
			x      = e.clientX - rect.left - down.x
			y      = e.clientY - rect.top - down.y
			down.x = e.clientX - rect.left
			down.y = e.clientY - rect.top

			# 加算
			if Math.abs x > Math.abs y
				@size += x
			else
				@size += y

			# サイズの制御
			max = 0
			if Math.abs @pos.x > Math.abs @pos.y
				max = Math.abs @pos.x
			else
				max = Math.abs @pos.y
			max = 300 - max
			if @size > max
				@size = max
			else if @size < 30
				@size = 30

			@preview_area.style.width  = @size + 'px'
			@preview_area.style.height = @size + 'px'

		# mouseup -------------------------------------
		window.addEventListener 'mouseup', (e) =>
			down = false

	##
	# チェックボタンのイベント
	##
	eventCheck: ->
		checks = @param_li.children

		for check, i in checks
			check.children[0].setAttribute 'data-num', i
			check.children[0].addEventListener 'click', (e) =>
				@passive() # 選択解除
				e.target.setAttribute 'data-state', 'active'

	##
	# 追加ボタン
	##
	eventAdd: ->
		# click ---------------------------------------
		@add_btn.addEventListener 'click', (e) =>
			name    = @layer_name.value.replace(' ', '')
			mesh    = parseInt @layer_mesh.value
			quality = @getParam()
			size    = @size / 300
			pos     = {
				x: @pos.x / 300
				y: @pos.y / 300
			}

			# 文字数
			if name.length > 20 or name.length < 1
				alert 'レイヤー名を入力してください'
				return

			# 文字列の正当性
			if not name.match(/[a-z0-9]+/)
				alert 'レイヤー名は半角英数字で入力しください'
				return

			# 重複
			if not @check name
				alert 'すでにその名前のレイヤー名は存在しています'
				return

			# メッシュ
			if not (mesh < 31 and mesh > 0)
				alert 'メッシュ数は1〜30の数値で入力してください'
				return

			@emit 'add', { # イベント発火
				name:    name    # レイヤー名
				mesh:    mesh    # メッシュ
				quality: quality # テクスチャパラメータ
				pos:     pos     # 切り出し位置
				size:    size    # サイズ
			}

	##
	# 選択解除
	##
	passive: ->
		checks = @param_li.children

		for check, i in checks
			check.children[0].setAttribute 'data-state', ''

	##
	# テクスチャパラメータの取得
	##
	getParam: ->
		checks = @param_li.children

		for check, i in checks
			state = check.children[0].getAttribute 'data-state'
			if state is 'active'
				return check.children[0].getAttribute 'data-val'

	##
	# 重複のチェック
	# @param name: レイヤー名
	##
	check: (name) ->
		layer = app_json.layer

		for l in layer
			_name = l.name
			if name is _name
				return false

		return true

	##
	# 閉じる
	##
	delete: ->
		@app.innerHTML = ''
	
module.exports = ImageView