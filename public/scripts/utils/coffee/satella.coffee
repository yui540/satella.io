class Satella
	constructor: (params) ->
		# state
		@scale         = 5.35
		@current_layer = -1

		# canvas
		@webgl = params.canvas
		@gl    = @webgl.getContext 'webgl', { preserveDrawingBuffer: true }

		# size
		@width  = params.width
		@height = params.height
		@resize @width, @height

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
			mvpMatrix          : @gl.getUniformLocation @prg, 'mvpMatrix'
			texture            : @gl.getUniformLocation @prg, 'texture'
			premultipliedAlpha : @gl.getUniformLocation @prg, 'premultipliedAlpha'

		# matrix
		@m_matrix   = @identity @create() # モデル変換行列
		@v_matrix   = @identity @create() # ビュー変換行列
		@p_matrix   = @identity @create() # プロジェクション変換行列
		@tmp_matrix = @identity @create()
		@mvp_matrix = @identity @create()

		# resource
		@images  = {}
		@texture = {}
		@model   = {
			meta      : [],
			layer     : [],
			parameter : []
		}

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
	multiply: (mat1, mat2, dest) ->
		a = mat1[0];  b = mat1[1];  c = mat1[2];  d = mat1[3];
		e = mat1[4];  f = mat1[5];  g = mat1[6];  h = mat1[7];
		i = mat1[8];  j = mat1[9];  k = mat1[10]; l = mat1[11];
		m = mat1[12]; n = mat1[13]; o = mat1[14]; p = mat1[15];
		A = mat2[0];  B = mat2[1];  C = mat2[2];  D = mat2[3];
		E = mat2[4];  F = mat2[5];  G = mat2[6];  H = mat2[7];
		I = mat2[8];  J = mat2[9];  K = mat2[10]; L = mat2[11];
		M = mat2[12]; N = mat2[13]; O = mat2[14]; P = mat2[15];
		dest[0]  = A * a + B * e + C * i + D * m;
		dest[1]  = A * b + B * f + C * j + D * n;
		dest[2]  = A * c + B * g + C * k + D * o;
		dest[3]  = A * d + B * h + C * l + D * p;
		dest[4]  = E * a + F * e + G * i + H * m;
		dest[5]  = E * b + F * f + G * j + H * n;
		dest[6]  = E * c + F * g + G * k + H * o;
		dest[7]  = E * d + F * h + G * l + H * p;
		dest[8]  = I * a + J * e + K * i + L * m;
		dest[9]  = I * b + J * f + K * j + L * n;
		dest[10] = I * c + J * g + K * k + L * o;
		dest[11] = I * d + J * h + K * l + L * p;
		dest[12] = M * a + N * e + O * i + P * m;
		dest[13] = M * b + N * f + O * j + P * n;
		dest[14] = M * c + N * g + O * k + P * o;
		dest[15] = M * d + N * h + O * l + P * p;
		return dest

	##
	#
	##
	lookAt: (eye, center, up, dest) ->
		eyeX    = eye[0];    eyeY    = eye[1];    eyeZ    = eye[2];
		upX     = up[0];     upY     = up[1];     upZ     = up[2];
		centerX = center[0]; centerY = center[1]; centerZ = center[2];

		if eyeX == centerX && eyeY == centerY && eyeZ == centerZ
			return @identity dest

		z0  = eyeX - center[0]; z1 = eyeY - center[1]; z2 = eyeZ - center[2];
		l   = 1 / Math.sqrt(z0 * z0 + z1 * z1 + z2 * z2);
		z0 *= l; z1 *= l; z2 *= l;
		x0  = upY * z2 - upZ * z1;
		x1  = upZ * z0 - upX * z2;
		x2  = upX * z1 - upY * z0;
		l   = Math.sqrt(x0 * x0 + x1 * x1 + x2 * x2);

		if not l
			x0 = 0; x1 = 0; x2 = 0;
		else
			l = 1 / l;
			x0 *= l; x1 *= l; x2 *= l;
		
		y0 = z1 * x2 - z2 * x1; y1 = z2 * x0 - z0 * x2; y2 = z0 * x1 - z1 * x0;
		l  = Math.sqrt(y0 * y0 + y1 * y1 + y2 * y2);

		if not l
			y0 = 0; y1 = 0; y2 = 0;
		else
			l = 1 / l;
			y0 *= l; y1 *= l; y2 *= l;
		
		dest[0]  = x0; dest[1] = y0; dest[2]  = z0; dest[3]  = 0;
		dest[4]  = x1; dest[5] = y1; dest[6]  = z1; dest[7]  = 0;
		dest[8]  = x2; dest[9] = y2; dest[10] = z2; dest[11] = 0;
		dest[12] = -(x0 * eyeX + x1 * eyeY + x2 * eyeZ);
		dest[13] = -(y0 * eyeX + y1 * eyeY + y2 * eyeZ);
		dest[14] = -(z0 * eyeX + z1 * eyeY + z2 * eyeZ);
		dest[15] = 1;
		return dest

	##
	#
	##
	perspective: (fovy, aspect, near, far, dest) ->
		t = near * Math.tan(fovy * Math.PI / 360);
		r = t * aspect;
		a = r * 2; b = t * 2; c = far - near;
		dest[0]  = near * 2 / a;
		dest[1]  = 0;
		dest[2]  = 0;
		dest[3]  = 0;
		dest[4]  = 0;
		dest[5]  = near * 2 / b;
		dest[6]  = 0;
		dest[7]  = 0;
		dest[8]  = 0;
		dest[9]  = 0;
		dest[10] = -(far + near) / c;
		dest[11] = -1;
		dest[12] = 0;
		dest[13] = 0;
		dest[14] = -(far * near * 2) / c;
		dest[15] = 0;
		return dest

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
	# サイズの変更
	# @param width  : 幅
	# @param height : 高さ
	##
	resize: (width, height) ->
		@width        = width
		@height       = height
		@webgl.width  = @width
		@webgl.height = @height

		@gl.viewport 0, 0, @width, @height
		return true

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
			attStride, 
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
 		p1    = 0
 		p2    = mesh * 3
 		p3    = (mesh + 1) * 3 * mesh
 		p4    = (((mesh + 1) * 3) * mesh) + (mesh * 3)
 		x     = @rate position[p1], position[p2], 0.5
 		y     = @rate position[p3 + 1], position[p1 + 1], 0.5
 		atari = [x, y]

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
 		@gl.texParameteri @gl.TEXTURE_2D, @gl.TEXTURE_MAG_FILTER, @gl.LINEAR
 		@gl.texParameteri @gl.TEXTURE_2D, @gl.TEXTURE_MIN_FILTER, mipmap 
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

		@model.layer.push {
			name          : params.name    # レイヤー名
			path          : params.path    # 画像パス
			mesh          : params.mesh    # メッシュ数
			quality       : params.quality # テクスチャパラメータ
			look          : 'show'         # 表示状態
			anchor        : []             # アンカーポイント
			position      : []             # 位置情報
			rotate        : 0              # 回転
			atari         : []             # アタリ
			color         : color          # 色情報
			texture_coord : tex            # テクスチャ情報
			index         : index          # インデックスバッファ
			parameter     : {}             # パラメータ
		}

		@loadResource params

	##
	# テクスチャの読み込み
	# @param params : 
	##
	loadResource: (params) ->
		img     = new Image()
		img.src = params.path
		num     = @model.layer.length - 1

		img.onload = =>
			# 初期の頂点座標
			position = @createPositionAttr params.mesh, params.pos, params.size
			@model.layer[num].position = position

			# 初期のアタリ
			atari = @initAtari position, params.mesh
			@model.layer[num].atari = atari

			# 初期のアンカーポイント
			anchor = @initAtari position, params.mesh
			@model.layer[num].anchor = anchor

			# テクスチャ
			@images[params.name]  = img
			@texture[params.name] = @createTexture img, params.quality

			# イベント発火
			@current_layer = @model.layer.length - 1
			@emit 'add', { name: params.name }

	##
	# レイヤーの並べ替え
	# @param num  : レイヤー番号
	# @param type : 'up' or 'down'
	##
	sort: (num, type) ->
		axis = null
		if type is 'up' then axis = num
		else                 axis = num - 1

		a1 = axis + 1
		a2 = axis

		@model.layer.splice(
			axis,
			2,
			@model.layer[a1],
			@model.layer[a2]
		)
		@emit 'sort'
		return true

	##
	# レイヤー番号の取得
	# @param  name : レイヤー名
	# @return i
	##
	getLayerPosition: (name) ->
		for layer, i in @model.layer
			if layer.name is name
				return i
		return false

	##
	# パラメータの取得
	# @param  name : パラメータ名
	# @return i
	##
	getParameterPosition: (name) ->
		for parameter, i in @model.parameter
			if parameter.name is name
				return i
		return false

	##
	# パラメータの追加
	# @param name : パラメータ名
	# @param type : パラメータタイプ
	# @param num  : 基準点の数
	##
	addParameter: (name, type, num) ->
		@model.parameter.push
			type  : type
			num   : num
			name  : name
			x     : 0.5
			y     : 0.5
			layer : []
		return true

	##
	# パラメータの消去
	# @param name : パラメータ名
	##
	removeParameter: (name) ->
		num   = @getParameterPosition name
		layer = @model.parameter[num].layer

		for l, i in layer
			delete @model.layer[i].parameter[name]
		@model.parameter.splice num, 1

		return true

	##
	# パラメータの登録
	# @param layer : レイヤー番号
	# @param name  : パラメータ名
	# @param type  : パラメータタイプ
	# @param num   : 基準点の数
	##
	registerParameter: (layer, name, type, num) ->
		num        = @getParameterPosition name
		mesh       = @model.layer[layer].mesh + 1
		layer_name = @model.layer[layer].name
		data       = []

		# move -------------------------------------------
		if type is 'move' and num is 2
			for i in [0...2]
				position = []
				for n in [0...(mesh * mesh * 3)]
					position.push 0.0
				data.push position
		else if type is 'move' and num is 4
			for i in [0...4]
				position = []
				for n in [0...(mesh * mesh * 3)]
					position.push 0.0
				data.push position

		# rotate -----------------------------------------
		else if type is 'rotate' and num is 2
			data = [0, 0]
		else
			data = [0, 0, 0, 0]

		@model.parameter[num].layer.push layer_name
		@model.layer[layer].parameter[name] = data
		return true

	##
	# パラメータの解除
	# @param layer : レイヤー番号
	# @param name  : パラメータ名
	##
	releaseParameter: (layer, name) ->
		num        = @getParameterPosition name
		layer_name = @model.layer[layer].name

		for l, i in @model.parameter[num].layer
			if l is layer_name
				@model.parameter[num].layer.splice i, 1

		delete @model.layer[layer].parameter[name]
		return true

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
		@lookAt([0.0, 0.0, @scale], [0.0, 0.0, 0.0], [0.0, 1.0, 0.0], 
			@v_matrix
		)
		@perspective(50, @width / @height, 0.1, 10,
			@p_matrix
		)
		@multiply @p_matrix,   @v_matrix, @tmp_matrix
		@multiply @tmp_matrix, @m_matrix, @mvp_matrix

	##
	# 描画
	##
	render: ->
		@clear()
		@viewMatrix()
		@blendType()
		@gl.enable @gl.BLEND

		for layer, num in @model.layer
			position      = layer.position
			color         = layer.color
			texture_coord = layer.texture_coord
			index         = layer.index
			view.render position, layer.mesh

			vPosition     = @createVBO position
			vColor        = @createVBO color
			vTextureCoord = @createVBO texture_coord
			iIndex        = @createIBO index

			@setAttribute vPosition,     @attLocation.position, @attStride.position
			@setAttribute vColor,        @attLocation.color,    @attStride.color
			@setAttribute vTextureCoord, @attLocation.texture,  @attStride.texture

			@gl.bindTexture @gl.TEXTURE_2D, @texture[layer.name]

			@gl.uniformMatrix4fv @uniLocation.mvpMatrix, false, @mvp_matrix
			@gl.uniform1f @uniLocation.vertexAlpha, 1.0
			@gl.bindBuffer @gl.ELEMENT_ARRAY_BUFFER, iIndex

			@gl.drawElements(
				@gl.TRIANGLES,
				layer.index.length,
				@gl.UNSIGNED_SHORT,
				0
			)

			@gl.bindTexture @gl.TEXTURE_2D, null
			@gl.bindBuffer @gl.ELEMENT_ARRAY_BUFFER, null

		@gl.flush()
		return true

	##
	# 頂点の移動（単体）
	# @param layer : レイヤー番号
	# @param num   : 頂点番号
	# @param pos   : 位置情報
	##
	moveVertex: (layer, num, pos) ->
		num *= 3
		@model.layer[layer].position[num]     = pos.x
		@model.layer[layer].position[num + 1] = pos.y

		return true

	##
	# 頂点座標の移動（パラメータ）
	# @param layer : レイヤー番号
	# @param param : パラメータ名
	# @param dire  : 方向番号
	# @param num   : 頂点番号
	# @param pos   : 位置情報
	##
	moveParamVertex: (layer, param, dire, num, pos) ->
		num *= 3
		x    = @model.layer[layer].position[num]
		y    = @model.layer[layer].position[num + 1]
		x    = @diff(x, pos.x) * -1
		y    = @diff(y, pos.y) * -1

		@model.layer[layer].parameter[param][dire][num]     = x
		@model.layer[layer].parameter[param][dire][num + 1] = y

		return true

try
	module.exports = Satella
catch
