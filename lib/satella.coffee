class Satella
	constructor: (params) ->
		# camera
		@scale = 5.35

		# size
		@width  = params.width
		@height = params.height

		# webgl
		@webgl = params.canvas
		@gl    = @webgl.getContext 'webgl', { 
			preserveDrawingBuffer: true 
		}

		# shader & program object
		v_shader = @createShader 'vs', @getVertexShader()
		f_shader = @createShader 'fs', @getFragmentShader()
		@prg     = @createProgramObj v_shader, f_shader

		# attribute
		@attLocation =
			position : @gl.getAttribLocation @prg, 'position'
			color    : @gl.getAttribLocation @prg, 'color'
			texture  : @gl.getAttribLocation @prg, 'textureCoord'

		@attStride = 
			position : 3
			color    : 4
			texture  : 2

		# uniform
		@uniLocation = 
				mvpMatrix : @gl.getUniformLocation @prg, 'mvpMatrix'
				texture   : @gl.getUniformLocation @prg, 'texture'

		# matrix
		@m_matrix   = @identity @create() # モデル変換行列
		@v_matrix   = @identity @create() # ビュー変換行列
		@p_matrix   = @identity @create() # プロジェクション変換行列
		@tmp_matrix = @identity @create()
		@mvp_matrix = @identity @create()

		# resource
		@json    = {
			meta  : [],
			layer : []
		}
		@images  = {}
		@texture = {}

		# listener
		@listeners = []

		# 深度
		@depth()

	##
	# イベントリスナの追加
	# @param event : イベント名
	# @param fn    : コールバック関数
	##
	on: (event, fn) ->
		@listeners.push 
			event : event
			fn    : fn

		return true

	##
	# イベントの発火
	# @param event : イベント名
	# @param data  : データ
	##
	emit: (event, data) ->
		for listener in @listeners
			if event is listener.event
				listener.fn data

		return true

	##
	# 行列の領域を確保
	# @return dest
	##
	create: ->
		return new Float32Array(16)

	##
	# 行列の初期化
	# @param  dest : 領域
	# @return dest
	##
	identity: (dest) ->
		dest[0]  = 1; dest[1]  = 0; dest[2]  = 0; dest[3]  = 0;
		dest[4]  = 0; dest[5]  = 1; dest[6]  = 0; dest[7]  = 0;
		dest[8]  = 0; dest[9]  = 0; dest[10] = 1; dest[11] = 0;
		dest[12] = 0; dest[13] = 0; dest[14] = 0; dest[15] = 1;

		return dest

	##
	#
	##
	lookAt: ->

	##
	# 2点の差分を取得
	# @param  a : 値1
	# @param  b : 値2
	# @return diff
	##
	diff: (a, b) ->
		diff = 0
		if a > b
			diff = a - b
		else
			diff = -(b - a)

		return diff

	##
	# 割合を掛け合わせる
	# @param  p1  : 最小値
	# @param  p2  : 最大値
	# @param  per : 割合
	# @return val
	##
	rate: (p1, p2, per) ->
		diff = @diff(p2, p1) * per
		val  = p1 + diff

		return val

	##
	# 深度
	##
	depth: ->
		@gl.enable @gl.DEPTH_TEST
		@gl.depthFunc @gl.LEQUAL

		return true

	##
	# 頂点シェーダの取得
	# @return vs
	##
	getVertexShader: ->
		return "
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
			}
		"

	##
	# フラグメントシェーダの取得
	# @return fs
	##
	getFragmentShader: ->
		return "
			precision mediump float;
			uniform sampler2D texture;
			uniform int premultipliedAlpha;
			varying vec4      vColor;
			varying vec2      vTextureCoord;

			void main(void){
			    vec4 smpColor = texture2D(texture, vTextureCoord);
			    vec4 color    = vec4(smpColor.rgb * vColor.rgb, smpColor.a * vColor.a);
			    color         = vec4(color.rgb * color.a, color.a);
			    gl_FragColor  = color;
			}
		"

	##
	# シェーダの生成
	# @param  type   : シェーダの種類
	# @param  shader : シェーダ
	# @return _shader
	##
	createShader: (type, shader) ->
		_shader = null
		if type is 'vs'
			_shader = @gl.createShader @gl.VERTEX_SHADER
		else
			_shader = @gl.createShader @gl.FRAGMENT_SHADER

		@gl.shaderSource _shader, shader
		@gl.compileShader _shader

		if @gl.getShaderParameter _shader, @gl.COMPILE_STATUS
			return _shader
		else 
			return false

	##
	# プログラムオブジェクトの生成
	# @param  v_shader : 頂点シェーダ
	# @param  f_shader : フラグメントシェーダ
	# @return prg
	##
	createProgramObj: (v_shader, f_shader) ->
		prg = @gl.createProgram()
		@gl.attachShader prg, v_shader
		@gl.attachShader prg, f_shader
		@gl.linkProgram prg

		if @gl.getProgramParameter prg, @gl.LINK_STATUS
			@gl.useProgram prg
			return prg
		else
			return false

	##
	# vboの生成
	# @param  data : 頂点属性のデータ
	# @return vbo
	##
	createVBO: (data) ->
		vbo = @gl.createBuffer()
		@gl.bindBuffer @gl.ARRAY_BUFFER, vbo
		@gl.bufferData @gl.ARRAY_BUFFER, new Float32Array(data), @gl.STATIC_DRAW
		@gl.bindBuffer @gl.ARRAY_BUFFER, null

		return vbo

	##
	#	iboの生成
	# @param  data : 頂点のデータ
	# @return ibo
	##
	createIBO: (data) ->
		ibo = @gl.createBuffer()
		@gl.bindBuffer @gl.ELEMENT_ARRAY_BUFFER, ibo
		@gl.bufferData @gl.ELEMENT_ARRAY_BUFFER, new Int16Array(data), @gl.STATIC_DRAW
		@gl.bindBuffer @gl.ELEMENT_ARRAY_BUFFER, null

		return ibo

	##
	# vboをバインド
	# @param vbo         : vbo
	# @param attLocation : attribute location
	# @param attStride   : attribute stride
	##
	setAttribute: (vbo, attLocation, attStride) ->
		@gl.bindBuffer @gl.ARRAY_BUFFER, vbo
		@gl.enableVertexAttribArray attLocation
		@gl.vertexAttribPointer(
			attLocation, 
			attachShader, 
			@gl.FLOAT, false, 0, 0
		)
		return true

	##
	# position属性の生成
	# @param  mesh     : メッシュ数
	# @param  position : 位置
	# @return position
	##
	createPositionAttr: (mesh, pos, size) ->
		position = []
		per      = 5 * size
		x        = null
		y        = null

		if per >= 5
			x = -(5 / 2)
			y = -(5 / 2)
		else
			x  = (pos.x * 5) - 2.5
			y  = ((1 - pos.y) * 5) - 2.5
			y -= per

		for i in [0..mesh]
			for n in [0..mesh]
				position.push (per * (n / mesh)) + x
				position.push (per * (1 - (i / mesh))) + y
				position.push 0.0

		return position

	##
	# color属性の生成
	# @param  mesh : メッシュ数
	# @return color
	##
	createColorAttr: (mesh) ->
		color  = []
		mesh  += 1
		size   = mesh * mesh * 4

		for i in [0..size]
			color.push 1.0

		return color

	##
	# texture属性の生成
	# @param  mesh : メッシュ数
	# @return tex
	##
	createTextureAttr: (mesh) ->
		tex = []

		for i in [0..mesh]
			for n in [0..mesh]
				tex.push n / mesh
				tex.push i / mesh

		return tex

	##
	# index属性の生成
	# @param  mesh : メッシュ数
	# @return index
	##
	createIndexAttr: (mesh) ->
		index = []
		t1    = [1, 0, (mesh + 1)]
		t2    = [(mesh + 2), (mesh + 1), 1]
		c     = 0

		for i in [0...(mesh * mesh)]
			if i isnt 0
				if (i % mesh) is 0
					c += 1
			index.push t1[0] + (i + c)
			index.push t1[1] + (i + c)
			index.push t1[2] + (i + c)
			index.push t2[0] + (i + c)
			index.push t2[1] + (i + c)
			index.push t2[2] + (i + c)
		return index

	##
 	# アタリ位置の設定
 	# @param  position : 頂点座標
 	# @param  mesh     : メッシュ数
 	# @return atari
 	##
	initAtari: (position, mesh) ->
 		p1     = 0
 		p2     = mesh * 3
 		p3     = (mesh + 1) * 3 * mesh
 		p4     = (((mesh + 1) * 3) * mesh) + (mesh * 3)
 		x      = @rate position[p1], position[p2], 0.5
 		y      = @rate position[p3 + 1], position[p1 + 1], 0.5
 		atari  = [x, y]

 		return atari

 	##
 	# ブレンドタイプの設定
 	##
 	blendType: ->
 		@gl.blendEquationSeparate(
 			@gl.FUNC_ADD,
 			@gl.FUNC_ADD
 		)
 		@gl.blendFuncSeparate(
 			@gl.ONE,
 			@gl.ONE_MINUS_SRC_ALPHA,
 			@gl.ONE,
 			@gl.ONE_MINUS_SRC_ALPHA
 		)

 		return true

 	##
 	# テクスチャの生成
 	# @param  img     : Image Object
 	# @param  quality : テクスチャパラメータ
 	# @return tex
 	##
 	createTexture: (img, quality) ->
 		mipmap = @gl[quality]
 		tex    = @gl.createTexture()

 		@gl.bindTexture @gl.TEXTURE_2D, tex
 		@gl.texImage2D(
 			@gl.TEXTURE_2D,
 			0,
 			@gl.RGBA, 
 			@gl.RGBA, 
 			@gl.UNSIGNED_BYTE, 
 			img
 		)
 		@gl.texParameteri(
 			@gl.TEXTURE_2D,
 			@gl.TEXTURE_MAG_FILTER,
 			@gl.LINEAR
 		)
 		@gl.texParameteri(
 			@gl.TEXTURE_2D,
 			@gl.TEXTURE_MIN_FILTER,
 			mipmap
 		)
 		@gl.generateMipmap @gl.TEXTURE_2D
 		@gl.bindTexture @gl.TEXTURE_2D, null

 		return tex

	##
	# レイヤーの追加
	# @param params : 
	##
	addLayer: (params) ->
		color = @createColorAttr   params.mesh
		tex   = @createTextureAttr params.mesh
		index = @createIndexAttr   params.mesh

		@json.layer.push {
			name          : params.name    # レイヤー名
			path          : params.path    # 画像パス
			mesh          : params.mesh    # メッシュ数
			quality       : params.quality # テクスチャパラメータ
			show          : true           # 表示状態
			anchor        : [0, 0]         # アンカーポイント
			position      : []             # 位置情報
			rotate        : []             # 回転
			atari         : []             # アタリ
			color         : color          # 色情報
			texture_coord : tex            # テクスチャ情報
			index         : index          # インデックスバッファ
		}

		@loadResource params

	##
	# テクスチャの読み込み
	# @param params : 
	##
	loadResource: (params) ->
		img     = new Image()
		img.src = params.path

		img.onload = =>
			num = @json.layer.length - 1

			# 初期の頂点座標
			position = @createPositionAttr params.mesh, params.pos, params.size
			@json.layer[num].position.push position

			# 初期のアタリ
			atari = @initAtari position, params.mesh
			@json.layer[num].atari = atari

			# テクスチャ
			@images[params.name]  = img
			@texture[params.name] = @createTexture img, params.quality

			# イベント発火
			@emit 'add', { name: params.name }

	##
	# 画面クリア
	##
	clear: ->
		@gl.clearColor 0.0, 0.0, 0.0, 0.0
		@gl.clearDepth 1.0
		@gl.clear @gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT
		return true

	##
	# ビュー&プロジェクション
	##
	viewMatrix: ->






