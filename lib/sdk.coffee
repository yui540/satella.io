vs = "
	attribute vec3 position;
	attribute vec4 color;
	attribute vec2 textureCoord;
	uniform   mat4 mvpMatrix;
	varying   vec4 vColor;
	varying   vec2 vTextureCoord;

	void main(void){
	    vColor        = color;
	    vTextureCoord = textureCoord;
	    gl_Position   = mvpMatrix * vec4(position, 1.0);
	}"

fs = "
	precision mediump float;

	uniform sampler2D texture;
	uniform int premultipliedAlpha;
	varying vec4      vColor;
	varying vec2      vTextureCoord;

	void main(void){
	    vec4 smpColor = texture2D(texture, vTextureCoord);
	    vec4 color = vec4(smpColor.rgb * vColor.rgb, smpColor.a * vColor.a);
	    color = vec4(color.rgb * color.a, color.a);
	    gl_FragColor  = color;
	}"

##
# Satella SDK
##
class Satella
	constructor: (params) ->
		# json
		@app_json  = {}
		@app_state = {}

		# element
		@app   = params.app
		@webgl = null

		# size
		@width  = params.width
		@height = params.height

		# texture
		@resource = {}
		@texture  = {}

		# timer
		@timer = null
		@max   = 0

		# listeners
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
	# コピー
	# @param obj: Object
	##
	copy: (obj) ->
		return JSON.parse JSON.stringify obj

	##
	# プロパティの数
	# @param obj: Object
	##
	len: (obj) ->
		i = 0
		for key, val of obj
			i++

		return i

	##
	# ２点の差分を取得
	# @param a: 対象1
	# @param b: 対象2
	##
	diff: (a, b) ->
		if a > b
			return a - b
		else
			return -(b - a)

	##
	# シェーダの生成
	# @param type: シェーダの種類
	# @param s:    シェーダ言語
	##
	createShader: (type, s) ->
		shader = null
		if type is 'vs'
			shader = @gl.createShader @gl.VERTEX_SHADER
		else if type is 'fs'
			shader = @gl.createShader @gl.FRAGMENT_SHADER

		@gl.shaderSource shader, s
		@gl.compileShader shader

		# 正しくコンパイルされたか
		if @gl.getShaderParameter shader, @gl.COMPILE_STATUS
			return shader
		else 
			console.error @gl.getShaderInfoLog shader 

	##
	# プログラムオブジェクトの生成
	# @param v_shader: 頂点シェーダ
	# @param f_shader: フラグメントシェーダ
	##
	createProgramObj: (v_shader, f_shader) ->
		prg = @gl.createProgram()
		@gl.attachShader prg, v_shader
		@gl.attachShader prg, f_shader
		@gl.linkProgram prg

		# 正しくリンクしたか
		if @gl.getProgramParameter(prg, @gl.LINK_STATUS)
			@gl.useProgram prg
			return prg
		else 
			console.error @gl.getProgramInfoLog prg

	##
	# vboの生成
	# @param data: 頂点属性のデータ
	##
	createVbo: (data) ->
		vbo = @gl.createBuffer()
		@gl.bindBuffer @gl.ARRAY_BUFFER, vbo
		@gl.bufferData @gl.ARRAY_BUFFER, new Float32Array(data), @gl.STATIC_DRAW
		@gl.bindBuffer @gl.ARRAY_BUFFER, null

		return vbo;

	##
	# iboの生成
	# @param data: 頂点属性のデータ
	##
	createIbo: (data) ->
		ibo = @gl.createBuffer()
		@gl.bindBuffer @gl.ELEMENT_ARRAY_BUFFER, ibo
		@gl.bufferData @gl.ELEMENT_ARRAY_BUFFER, new Int16Array(data), @gl.STATIC_DRAW
		@gl.bindBuffer @gl.ELEMENT_ARRAY_BUFFER, null

		return ibo

	##
	# 描画
	##
	render: ->
		@webgl = document.createElement 'canvas'
		@webgl.width  = @width
		@webgl.height = @height

		@gl = @webgl.getContext 'webgl', { 
			preserveDrawingBuffer: true 
		}

		@app.appendChild @webgl # ビューの設置
		@initShader()           # シェーダの初期化
		@initProgramObj()       # プログラムオブジェの初期化
		@initAttribute()        # 属性の初期化
		@initUniform()          # ユニフォームの初期化
		@initMatrix()           # 行列の初期化
		@depth()                # 深度
		@loadJSON()             # app.jsonの読み込み

	##
	# シェーダの初期化
	##
	initShader: ->
		@v_shader = @createShader 'vs', vs # vertex shader
		@f_shader = @createShader 'fs', fs # fragment shader

	##
	# プログラムオブジェの初期化
	##
	initProgramObj: ->
		@prg = @createProgramObj @v_shader, @f_shader

	##
	# 属性の初期化
	##
	initAttribute: ->
		@attLocation = {
			"position": @gl.getAttribLocation @prg, 'position'
			"color":    @gl.getAttribLocation @prg, 'color'
			"texture":  @gl.getAttribLocation @prg, 'textureCoord'
		}
		@attStride = {
			"position": 3 # 頂点座標
			"color":    4 # 色
			"texture":  2 # テクスチャ座標
		}

	##
	# ユニフォームの初期化
	##
	initUniform: ->
		@uniLocation = {
			"mvpMatrix":          @gl.getUniformLocation @prg, 'mvpMatrix' 
			"texture":            @gl.getUniformLocation @prg, 'texture'
			"premultipliedAlpha": @gl.getUniformLocation @prg, 'premultipliedAlpha'
		}

	##
	# 行列の初期化
	##
	initMatrix: ->
		@m = new matIV()
		@m_matrix   = @m.identity @m.create() # モデル変換行列
		@v_matrix   = @m.identity @m.create() # ビュー変換行列
		@p_matrix   = @m.identity @m.create() # プロジェクション変換行列
		@tmp_matrix = @m.identity @m.create()
		@mvp_matrix = @m.identity @m.create()

	##
	# 深度
	##
	depth: ->
		@gl.enable @gl.DEPTH_TEST
		@gl.depthFunc @gl.LEQUAL

	##
	# vboをバインド
	# @param vbo:         vbo
	# @param attLocation: attribute location
	# @param attStride:   attribute stride
	##
	setAttribute: (vbo, attLocation, attStride) ->
		@gl.bindBuffer @gl.ARRAY_BUFFER, vbo
		@gl.enableVertexAttribArray attLocation
		@gl.vertexAttribPointer attLocation, attStride, @gl.FLOAT, false, 0, 0

	##
	# テクスチャの生成
	# @param img:     Image Object
	# @param quality: テクスチャパラメータ
	##
	createTexture: (img, quality) ->
		mipmap = @gl[quality]
		tex    = @gl.createTexture()

		@gl.bindTexture @gl.TEXTURE_2D, tex
		@gl.texImage2D @gl.TEXTURE_2D, 0, @gl.RGBA, @gl.RGBA, @gl.UNSIGNED_BYTE, img
		@gl.texParameteri @gl.TEXTURE_2D, @gl.TEXTURE_MAG_FILTER, @gl.LINEAR
		@gl.texParameteri @gl.TEXTURE_2D, @gl.TEXTURE_MIN_FILTER, mipmap
		@gl.generateMipmap @gl.TEXTURE_2D
		@gl.bindTexture @gl.TEXTURE_2D, null

		return tex

	##
	# jsonの読み込み
	##
	loadJSON: ->
		req = new XMLHttpRequest()
		req.open 'GET', 'satella-sdk/lib/app.json'
		req.onreadystatechange = =>
			if req.readyState is 4
				@app_json = JSON.parse req.responseText

				# リソースの読み込み
				@loadResource()

				# アプリケーション状態の初期化
				@initAppState()
		req.send()

	##
	# リソースの読み込み
	##
	loadResource: ->
		layer = @app_json.layer
		for l in layer
			name    = l.name
			url     = 'satella-sdk/' + l.url
			quality = l.quality

			# 単一リソースの読み込み
			@loadOne name, url, quality

	##
	# 単一のリソース読み込み
	# @param name:    レイヤー名
	# @param url:     URL
	# @param quality: テクスチャパラメータ
	##
	loadOne: (name, url, quality) ->
		len = @app_json.layer.length
		img = new Image()
		img.src = url

		# load ------------------------------------------
		img.onload = (e) =>
			@resource[name] = img
			@texture[name]  = @createTexture img, quality

			# 終了
			if @len(@texture) >= len
				@loop()      # 描画ループ
				@emit 'load' # イベント発火
				
	##
	# アプリケーション状態の初期化
	##
	initAppState: ->
		@app_state = {
			play:      false
			time:      0
			keyframes: false
			scale:     1
			position:  { x: 0.5, y: 0.5 }
			parameter: {}
		}

		for name, param of @app_json.parameter
			type = param.type
			per  = {}
			if type is 4
				per = { x: 0.5, y: 0.5 }
			else
				per = { x: 0.5 }
			@app_state.parameter[name] = per

	##
	# ブレンドタイプの設定
	# @param param: 0 or 1
	##
	blendType: (param) ->
		switch param
			when 0 # 透過処理
				@gl.blendEquationSeparate @gl.FUNC_ADD, @gl.FUNC_ADD
				@gl.blendFuncSeparate @gl.ONE, @gl.ONE_MINUS_SRC_ALPHA, @gl.ONE, @gl.ONE_MINUS_SRC_ALPHA
			when 1 # 加算処理
				@gl.blendFunc @gl.SRC_ALPHA, @gl.ONE

	##
	# 中間点の取得
	# @param points: ポイントの集合
	# @param type:   パラメータタイプ
	##
	getMiddle: (points, type) ->
		time   = @app_state.time
		length = points.length

		if length is 0      # ポイント0個
			point = {}
			if type is 4
				point = { x: 0.5, y: 0.5 }
			else
				point = { x: 0.5 }
			return point
		else if length is 1 # ポイント1個
			return points[0]

		for i in [0..length - 2]
			time1 = points[i].time
			time2 = points[i+1].time
			_time = time - time1
			range = time2 - time1
			x1    = points[i].x
			y1    = points[i].y
			x2    = points[i+1].x
			y2    = points[i+1].y

			if time1 <= time and time2 >= time
				per    = _time / range
				d_x    = @diff(x2, x1) * per
				x      = x1 + d_x
				d_y    = 0
				y      = 0
				middle = {}

				middle.x = x

				if y1 isnt undefined
					d_y      = @diff(y2, y1) * per
					y        = y1 + d_y
					middle.y = y

				return middle

		first = points[0].time
		last  = points[length - 1].time

		if time < first
			return points[0]
		else if time > last
			return points[length - 1]

	##
	# 移動量の取得
	# @param layer: レイヤー名
	##
	getMove: (layer) ->
		move      = @copy @app_json.layer[layer].move
		parameter = @app_json.layer[layer].parameter
		keyframes = @app_state.keyframes

		for p_name of parameter
			param = parameter[p_name].move
			x     = @app_state.parameter[p_name].x
			y     = @app_state.parameter[p_name].y
			dire_x = p_x = 0
			dire_y = p_y = 0

			# moveなし
			if param is undefined
				continue

			# keyframesの追加
			if keyframes isnt false
				points = @app_json.keyframes[keyframes][p_name]
				m      = @getMiddle points
				x = m.x
				y = m.y

			if x > 0.5     # right
				dire_x = 1
				p_x    = (x - 0.5) / 0.5
			else           # left
				dire_x = 0
				p_x    = Math.abs(0.5 - x) / 0.5
			if y isnt undefined
				if y > 0.5 # bottom
					dire_y = 3
					p_y    = (y - 0.5) / 0.5
				else       # top
					dire_y = 2
					p_y    = Math.abs(0.5 - y) / 0.5

			if y is undefined
				move.x += param[dire_x].x * p_x
				move.y -= param[dire_x].y * p_x
			else
				move.x += param[dire_x].x * p_x
				move.y -= param[dire_y].y * p_y

			return move

	##
	# 回転量の取得
	# @param layer: レイヤー番号
	##
	getRotate: (layer) ->
		rotate    = @copy @app_json.layer[layer].rotate
		parameter = @app_json.layer[layer].parameter
		keyframes = @app_state.keyframes

		for p_name of parameter
			param = parameter[p_name].rotate

			# rotateなし
			if param is undefined
				continue

			p_x = @app_state.parameter[p_name].x

			# keyframesの追加
			if keyframes isnt false
				points = @app_json.keyframes[keyframes][p_name]
				m      = @getMiddle points
				p_x = m.x

			if p_x > 0.5 # right
				dire_x = 1
				p_x    = (p_x - 0.5) / 0.5
			else         # left
				dire_x = 0
				p_x    = Math.abs(0.5 - p_x) / 0.5

			rotate += param[dire_x] * p_x

		return rotate

	##
	# 全ての計算を終えた頂点座標の取得
	# @param layer: レイヤー番号
	##
	getPosition: (layer) ->
		position = @copy @app_json.layer[layer].init_position

		# 差分の吸収
		position = @diffPosition layer, position

		# 移動
		position = @movePosition layer, position

		# 回転
		position = @rotatePosition layer, position

		return position

	##
	# 頂点座標の拡大縮小
	##
	scale: (position) ->
		per_x = per_y = 0
		if @app_state.position.x < 0.5 # x
			per_x = 5 * ((@app_state.position.x - 0.5) / 1)
		else
			per_x = 5 * ((@app_state.position.x - 0.5) / 1)
		if @app_state.position.y < 0.5 # y
			per_y = 5 * ((0.5 - @app_state.position.y) / 1)
		else
			per_y = 5 * (-(@app_state.position.y - 0.5) / 1)
		
		length = position.length / 3
		for n in [0..length - 1]
			i = n * 3
			position[i]   += per_x
			position[i]   *= @app_state.scale
			position[i+1] += per_y
			position[i+1] *= @app_state.scale

		return position

	##
	# 差分の吸収した頂点座標
	# @param layer:    レイヤー番号
	# @param position: 頂点座標
	##
	diffPosition: (layer, position) ->
		parameter = @app_json.layer[layer].parameter
		keyframes = @app_state.keyframes

		for p_name of parameter
			param  = parameter[p_name].position
			type   = @app_json.parameter[p_name].type
			x      = @app_state.parameter[p_name].x
			y      = @app_state.parameter[p_name].y
			dire_x = p_x = 0
			dire_y = p_y = 0

			# diffなし
			if param is undefined
				continue

			# keyframes追加
			if keyframes isnt false
				points = @app_json.keyframes[keyframes][p_name]
				m      = @getMiddle points, type
				x = m.x
				y = m.y

			if x > 0.5     # right
				dire_x = 1
				p_x    = (x - 0.5) / 0.5
			else           # left
				dire_x = 0
				p_x    = Math.abs(0.5 - x) / 0.5
			if y isnt undefined
				if y > 0.5 # bottom
					dire_y = 3
					p_y    = (y - 0.5) / 0.5
				else       # top
					dire_y = 2
					p_y    = Math.abs(0.5 - y) / 0.5

			length = param[dire_x].length / 3
			if y is undefined # 2点パラメータ
				for n in [0..length - 1]
					i = n * 3
					position[i]   += param[dire_x][i] * p_x
					position[i+1] += param[dire_x][i+1] * p_x
			else              # 4点パラメータ
				for n in [0..length - 1]
					i = n * 3
					position[i]   += param[dire_x][i] * p_x
					position[i+1] += param[dire_y][i+1] * p_y

		return position

	##
	# 移動の頂点座標
	# @param layer:     レイヤー番号
	# @param @position: 頂点座標
	##
	movePosition: (layer, position) ->
		move   = @getMove layer
		length = position.length / 3

		for i in [0..length - 1]
			n = i * 3
			position[n]   += move.x
			position[n+1] -= move.y

		return position

	##
	# 回転の頂点座標
	# @param layer:    レイヤー番号
	# @param position: 頂点座標
	##
	rotatePosition: (layer, position) ->
		rotate = @getRotate layer
		x      = @app_json.layer[layer].anchor.x
		y      = @app_json.layer[layer].anchor.y
		length = position.length / 3

		for i in [0..length - 1]
			n        = i * 3
			x2       = position[n]
			y2       = position[n+1]
			rot      = Math.atan2(y2 - y, x2 - x) * 180 / Math.PI
			distance = Math.sqrt((x2 - x) * (x2 - x) + (y2 - y) * (y2 - y))

			rot += rotate

			rad = rot *  Math.PI / 180
			sin = Math.sin rad
			cos = Math.cos rad

			position[n]   = (cos * distance) + x
			position[n+1] = (sin * distance) + y

		return position

	##
	# 画面クリア
	##
	clear: ->
		@gl.clearColor 0.0, 0.0, 0.0, 0.0
		@gl.clearDepth 1.0
		@gl.clear @gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT

	##
	# ビュー & プロジェクション
	##
	viewMatrix: ->
		@m.lookAt(
			[0.0, 0.0, 5.35], 
			[0.0, 0.0, 0.0], 
			[0.0, 1.0, 0.0], 
			@v_matrix)
		@m.perspective(
			50, 
			@width / @height, 
			0.1, 
			100, 
			@p_matrix)
		@m.multiply @p_matrix, @v_matrix, @tmp_matrix
		@m.multiply @tmp_matrix, @m_matrix, @mvp_matrix

	##
	# 描画
	##
	draw: ->
		@clear()             # クリア
		@viewMatrix()        # ビュー設定
		@blendType 0         # ブレンドタイプ
		@gl.enable @gl.BLEND # ブレンドの有効

		length = @app_json.layer.length
		if length <= 0
			return

		for key in [0..length - 1]
			position      = @getPosition key
			color         = @copy @app_json.layer[key].color
			texture_coord = @copy @app_json.layer[key].texture_coord
			index         = @copy @app_json.layer[key].index
			show          = @app_json.layer[key].show

			# 拡大縮小
			position = @scale position

			# 表示
			if not position
				continue
			if show is 'hidden'
				continue

			# vbo $ iboの生成
			@vPosition     = @createVbo position
			@vColor        = @createVbo color
			@vTextureCoord = @createVbo texture_coord
			@iIndex        = @createIbo index

			# vbo & iboの登録
			@setAttribute @vPosition, @attLocation.position, @attStride.position
			@setAttribute @vColor, @attLocation.color, @attStride.color
			@setAttribute @vTextureCoord, @attLocation.texture, @attStride.texture

			# テクスチャのバインド
			@gl.bindTexture @gl.TEXTURE_2D, @texture[@app_json.layer[key].name]

			# uniform変数の登録
			@gl.uniformMatrix4fv @uniLocation.mvpMatrix, false, @mvp_matrix
			@gl.uniform1i @uniLocation.texture, 0
			@gl.bindBuffer @gl.ELEMENT_ARRAY_BUFFER, @iIndex

			@gl.drawElements @gl.TRIANGLES, @app_json.layer[key].index.length, @gl.UNSIGNED_SHORT, 0

		@gl.flush()

	##
	# 描画ループ
	##
	loop: ->
		fps = 1000 / 30
		@timer = setInterval =>
			# アニメーション
			if @app_state.keyframes isnt false
				if @app_state.time > @max
					name = @app_state.keyframes
					@app_state.keyframes = false
					@app_state.time      = 0
					@emit 'end', name
					return
				@app_state.time += 2

			# 描画
			@draw()
		, fps

	##
	# パラメータ情報一覧の取得
	##
	getParamList: ->
		parameter = @app_json.parameter
		return @copy parameter

	##
	# パラメータの状態一覧の取得
	##
	getParamStateList: ->
		parameter = @app_state.parameter
		return @copy parameter

	##
	# パラメータの情報取得
	# @param name: パラメータ名
	##
	getParam: (name) ->
		parameter = @app_json.parameter

		for _name, data of parameter
			if name is _name
				return @copy data

		return false

	##
	# パラメータの状態の取得
	# @param name: パラメータ名
	##
	getParamState: (name) ->
		parameter = @app_state.parameter

		for _name, data of parameter
			if name is _name
				return @copy data

		return false

	##
	# パラメータの設定
	# @param name: パラメータ名
	# @param val:  値x & 値y
	##
	setParam: (name, val) ->
		parameter = @app_json.parameter[name]

		# パラメータなし
		if parameter is undefined
			return false

		per  = {}
		type = parameter.type
		if type is 4 # 4点パラメータ
			per = { x: val.x, y: val.y }
		else         # 回転・2点パラメータ
			per = { x: val.x }

		@app_state.parameter[name] = per
		@emit 'change', { # イベント発火
			name: parameter
			val:  per
		}
		return true

	##
	# アニメーション
	# @param name: アニメーション名
	##
	animate: (name) ->
		@app_state.time      = 0
		@app_state.keyframes = name
		@max = @getDuration name
		@emit 'start', @app_state.keyframes

	##
	# 再生時間の取得
	# @param name: アニメーション名
	##
	getDuration: (name) ->
		max = 0
		for p_name of @app_json.keyframes[name]
			points = @app_json.keyframes[name][p_name]
			_max   = points[points.length - 1].time
			if max < _max
				max = _max

		return max

	##
	# レイヤー一覧の取得
	##
	getLayerList : ->
		layer = @copy @app_json.layer

		return layer

	##
	# レイヤーの取得
	# @param name: レイヤー名
	##
	getLayer: (name) ->
		layer = @copy @app_json.layer

		for l in layer
			_name = l.name
			if name is _name
				return l

	##
	# レイヤーの表示
	# @param name: レイヤー名
	##
	show: (name) ->
		layer = @app_json.layer

		for l in layer
			_name = l.name
			if name is _name
				l.show = 'show'

	##
	# レイヤーの非表示
	# @param name: レイヤー名
	##
	hidden: (name) ->
		layer = @app_json.layer

		for l in layer
			_name = l.name
			if name is _name
				l.show = 'hidden'