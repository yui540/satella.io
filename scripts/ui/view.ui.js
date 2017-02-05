var vs = `
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
	}`;
var fs = `
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
	}`;

/**
 * View
 * @param app: 埋め込み要素
 * @param width: 幅
 * @param height: 高さ
 */
function View(params) {
	this.std_width    = 600;                          // std_width
	this.std_height   = 600;                          // std_height
	this.std_aspect   = this.std_width / this.height; // std_aspect
	this.width        = params.width;                 // width
	this.height       = params.height;                // height
	this.aspect       = this.width / this.height;     // aspect
	this.webgl_width  = 0;                            // webgl_width
	this.webgl_height = 0;                            // webgl_height
	this.webgl_x      = 0;                            // webgl_x
	this.webgl_y      = 0;                            // webgl_y

	if(this.aspect > this.std_aspect)                 // layout
		this.layout = 'side';
	else
		this.layout = 'ver';
	
	this.app    = params.app;
	this.view   = null; // View
	this.webgl  = null; // WebGL
	this.canvas = null; // Canvas

	this.layoutStruct(); 

	// Navigator
	this.navigator = new Navigator(this, this.canvas);

	// Context
	this.gl = this.webgl.getContext(
		'webgl', {preserveDrawingBuffer: true});

	// Shader
	this.v_shader = this.createShader('vs', vs); // vertex shader
	this.f_shader = this.createShader('fs', fs); // fragment shader

	// Program Object
	this.prg = this.createProgramObj(this.v_shader, this.f_shader);

	// Attribute
	this.attLocation = {
		"position": this.gl.getAttribLocation(this.prg, 'position'),
		"color":    this.gl.getAttribLocation(this.prg, 'color'),
		"texture":  this.gl.getAttribLocation(this.prg, 'textureCoord')
	};
	this.attStride = {
		"position": 3, // 頂点座標
		"color":    4, // 色
		"texture":  2  // テクスチャ座標
	};

	// Uniform
	this.uniLocation = {
		"mvpMatrix":          this.gl.getUniformLocation(this.prg, 'mvpMatrix'),
		"texture":            this.gl.getUniformLocation(this.prg, 'texture'),
		"premultipliedAlpha": this.gl.getUniformLocation(this.prg, 'premultipliedAlpha')
	};

	// 深度
	this.depth();
	
	// Matrix
	this.m = new matIV();
	this.m_matrix   = this.m.identity(this.m.create()); // モデル変換行列
	this.v_matrix   = this.m.identity(this.m.create()); // ビュー変換行列
	this.p_matrix   = this.m.identity(this.m.create()); // プロジェクション変換行列
	this.tmp_matrix = this.m.identity(this.m.create());
	this.mvp_matrix = this.m.identity(this.m.create());

	// Texture
	this.resource = {};    // リソース
	this.texture  = {};    // テクスチャ

	// Data
	this.current_position = false;
	this.view_param       = 5.35;
}

/**
 * 深度
 */
View.prototype.depth = function() {
	this.gl.enable(this.gl.DEPTH_TEST);
	this.gl.depthFunc(this.gl.LEQUAL);
};

/**
 * 要素の設置
 */
View.prototype.setElement = function() {
	this.view      = document.createElement('div');
	this.view.id   = 'satella';
	this.webgl     = document.createElement('canvas');
	this.webgl.id  = 'webgl';
	this.canvas    = document.createElement('canvas');
	this.canvas.id = 'canvas';

	this.view.appendChild(this.webgl);
	this.view.appendChild(this.canvas);
	this.app.appendChild(this.view);
};

/**
 * レイアウト構成
 */
View.prototype.layoutStruct = function() {
	this.setElement(); // 要素の設置

	if(this.layout !== 'side') 
		var zoom = this.height / this.std_height;
	else 
		var zoom = this.width / this.std_width;

	this.webgl_width  = this.std_width * zoom;
	this.webgl_height = this.std_height * zoom;
	this.webgl_x      = (this.width - this.webgl_width) / 2;
	this.webgl_y      = (this.height - this.webgl_height) / 2;

	this.webgl.width   = this.webgl_width;
	this.webgl.height  = this.webgl_height;
	this.canvas.width  = this.width;
	this.canvas.height = this.height;

	let style = `
		#satella {
			position: absolute;     top: 0;
			width: ${this.width}px; height: ${this.height}px;
		}
		#webgl {
			position: absolute;
			top: ${this.webgl_y}px; left: ${this.webgl_x}px;
			background-color: #fff;
		}
		#canvas {
			position: absolute;     top: 0;
		}
	`.replace(/(\t|\n)/g, '');

	document.getElementById("view-style").innerHTML = style;
};

/**
 * シェーダの生成
 * @param type: シェーダの種類
 * @param s: シェーダ言語のコード
 * @return shader: シェーダ
 */
View.prototype.createShader = function(type, s) {
	// 頂点シェーダ or フラグメントシェーダ
	let shader;
	if(type === 'vs')
		shader = this.gl.createShader(this.gl.VERTEX_SHADER);
	else if(type === 'fs')
		shader = this.gl.createShader(this.gl.FRAGMENT_SHADER);

	this.gl.shaderSource(shader, s);
	this.gl.compileShader(shader);

	// 正しくコンパイルされたか
	if(this.gl.getShaderParameter(shader, this.gl.COMPILE_STATUS))
		return shader;
	else 
		console.error(this.gl.getShaderInfoLog(shader));
};

/**
 * プログラムオブジェクトの生成
 * @param v_shader: 頂点シェーダ
 * @param f_shader: フラグメントシェーダ
 * @return prg: プログラムオブジェクト
 */
View.prototype.createProgramObj = function(v_shader, f_shader) {
	let prg = this.gl.createProgram();
	this.gl.attachShader(prg, v_shader);
	this.gl.attachShader(prg, f_shader);
	this.gl.linkProgram(prg);

	// 正しくリンクしたか
	if(this.gl.getProgramParameter(prg, this.gl.LINK_STATUS)) {
		this.gl.useProgram(prg);
		return prg;
	} else 
		console.error(this.gl.getProgramInfoLog(prg));
};

/**
 * vboの生成
 * @param data: 頂点属性のデータ
 * @return vbo: 生成したvbo
 */
View.prototype.createVbo = function(data) {
	let vbo = this.gl.createBuffer();
	this.gl.bindBuffer(this.gl.ARRAY_BUFFER, vbo);
	this.gl.bufferData(this.gl.ARRAY_BUFFER, 
		new Float32Array(data), this.gl.STATIC_DRAW);
	this.gl.bindBuffer(this.gl.ARRAY_BUFFER, null);

	return vbo;
};

/**
 * iboの生成
 * @param data: 頂点属性のデータ
 * @return vbo: 生成したibo
 */
View.prototype.createIbo = function(data) {
	let ibo = this.gl.createBuffer();
	this.gl.bindBuffer(this.gl.ELEMENT_ARRAY_BUFFER, ibo);
	this.gl.bufferData(
		this.gl.ELEMENT_ARRAY_BUFFER, 
		new Int16Array(data), this.gl.STATIC_DRAW);
	this.gl.bindBuffer(this.gl.ELEMENT_ARRAY_BUFFER, null);

	return ibo;
};

/**
 * vboをバインド
 * @param vbo: vbo
 * @param attLocation: attribute location
 * @param attStride: attribute stride
 */
View.prototype.setAttribute = function(vbo, attLocation, attStride) {
	this.gl.bindBuffer(this.gl.ARRAY_BUFFER, vbo);
	this.gl.enableVertexAttribArray(attLocation);
	this.gl.vertexAttribPointer(
		attLocation, 
		attStride, 
		this.gl.FLOAT, false, 0, 0);
};

/**
 * position属性の生成
 * @param mesh: mesh数
 */
View.prototype.createPositionAttr = function(mesh, pos, size) {
	let per = 5 * size
	,   x, y;
	if(per >= 5) {
		x = -(5 / 2)
		y = -(5 / 2);
	} else {
		x  = (pos.x * 5) - 2.5
		y  = ((1 - pos.y) * 5) - 2.5;
		y -= per;
	}

	let position = [];
	for(let i=0; i <= mesh; i++) {
		for(let n=0; n <= mesh; n++) {
			position.push((per * (n / mesh)) + x);
			position.push((per * (1 - (i / mesh))) + y);
			position.push(0.0);
		}
	}

	return copy(position);
};

/**
 * color属性の生成
 * @param mesh: mesh数
 */
View.prototype.createColorAttr = function(mesh) {
	let color = [];
	mesh += 1;
	for(let i=0; i <= (mesh * mesh * 4); i++) 
		color.push(1.0);

	return copy(color);
};

/**
 * texture属性の生成
 * @param mesh: mesh数
 */
View.prototype.createTextureAttr = function(mesh) {
	let tex = [];
	for(let i=0; i <= mesh; i++) {
		for(let n=0; n <= mesh; n++) {
			tex.push(n / mesh);
			tex.push(i / mesh);
		}
	}

	return copy(tex);
};

/**
 * index属性の生成
 * @param mesh: mesh数
 */
View.prototype.createIndexAttr = function(mesh) {
	let index = []
	,   t1    = [1, 0, (mesh + 1)]
	,   t2    = [(mesh + 2), (mesh + 1), 1]
	,   c     = 0;

	for(let i=0; i < mesh * mesh; i++) {
		if(i!==0) if((i % mesh) === 0) c += 1;
		index.push(t1[0] + (i + c)); 
		index.push(t1[1] + (i + c)); 
		index.push(t1[2] + (i + c));
		index.push(t2[0] + (i + c)); 
		index.push(t2[1] + (i + c)); 
		index.push(t2[2] + (i + c));
	}

	return copy(index);
};

/**
 * 初期の中心
 * @param position: 頂点座標
 */
View.prototype.initCenter = function(position, mesh) {
	// 4点
	let p1 = 0
	,   p2 = (mesh * 3)
	,   p3 = ((mesh + 1) * 3) * mesh
	,   p4 = (((mesh + 1) * 3) * mesh) + (mesh * 3);
	
	let x = yuki540.rate(position[p1], position[p2], 0.5)
	,   y = yuki540.rate(position[p3+1], position[p1+1], 0.5);

	return { x: x, y: y };
};

/**
 * レイヤーの追加
 */
View.prototype.addLayer = function(params) {
	let color = this.createColorAttr(params.mesh)
	,   tex   = this.createTextureAttr(params.mesh)
	,   index = this.createIndexAttr(params.mesh);

	app_json.layer.push({
		"name":           params.name,   // レイヤー名
		"url":            params.url,    // 画像パス
		"mesh":           params.mesh,   // メッシュ数
		"anchor": {                      // アンカーポイント
			x: 0, y: 0
		},
		"move": {                        // 移動
			x: 0, y: 0
		},
		"center":        {},             // 中心
		"rotate":        0,              // 回転
		"show":          'show',         // 表示状態
		"quality":       params.quality, // テクスチャパラメータ
		"init_position": [],             // 初期の座標行列
		"parameter":     {},             // パラメータ 
		"color":         color,          // 色情報
		"texture_coord": tex,            // テクスチャ情報
		"index":         index,          // インデックスバッファ
	});

	this.loadResource(params); // テクスチャの読み込み
};

/**
 * テクスチャの読み込み
 */
View.prototype.loadResource = function(params) {
	let self      = this
	,   img       = new Image()
	,   name      = params.name
	,   mesh      = params.mesh
	,   pos       = params.pos
	,   quality   = params.quality
	,   size      = params.size
	,   file_path = 'file://' + app_state.directory + params.url;

	img.src = file_path;
	img.onload = function() {
		let num  = app_json.layer.length - 1;

		// 初期の頂点座標
		app_json.layer[num].init_position = 
			self.createPositionAttr(mesh, pos, size);

		// 初期の中心
		app_json.layer[num].center = 
			self.initCenter(app_json.layer[num].init_position, mesh);

		// テクスチャ
		self.resource[name] = img;
		self.texture[name]  = self.createTexture(img, quality);

		// 選択レイヤーの更新
		app_state.setState('current_layer', num);

		// 履歴の更新
		UI.history.pushHistory();
	};
};

/**
 * 起動時の事前読み込み
 * @param callback: コールバック関数
 */
View.prototype.initLoadResource = function(callback) {
	let self     = this
	,   load     = 0
	,   layer    = app_json.layer
	,   length   = app_json.layer.length - 1;

	for(let i=0; i <= length; i++) {
		let img      = new Image()
		,   name     = layer[i].name
		,   quality  = layer[i].quality
		,   img_path = app_state.directory + layer[i].url;

		img.src    = img_path;
		img.onload = function() {
			self.texture[name] = img;
			self.texture[name] = self.createTexture(img, quality);
			if(load >= length)
				callback();
			else 
				load++; 
		};
	}
};

/**
 * パラメータの追加
 */
View.prototype.addParameter = function(key, type, name) {
	let pos      = copy(app_json.layer[key].init_position)
	,   position = [];

	for(let k in app_json.layer[key].parameter) {   // 重複のチェック
		let tmp_name = k.toString();
		if(name === tmp_name) 
			return false;
	}

	for(let i=0; i < type; i++) {                   // 初期化
		position[i] = [];
		for(let n=0; n < pos.length; n++) 
			position[i][n] = 0.0;
	}

	if(type === 4) { // --------------------------- 4点パラメータ
		app_json.layer[key].parameter[name] = {
			position: copy(position),
			move: [
				{ x: 0, y: 0 }, { x: 0, y: 0 },
				{ x: 0, y: 0 }, { x: 0, y: 0 }
			]
		}
	} else if(type === 2) { // -------------------- 2点パラメータ
		app_json.layer[key].parameter[name] = {
			position: copy(position),
			move: [
				{ x: 0, y: 0 }, { x: 0, y: 0 }
			]
		}
	} else { // ----------------------------------- 回転パラメータ
		app_json.layer[key].parameter[name] = {
			rotate: [0, 0]
		}
	}
	return true;
};

/**
 * ブレンドタイプの設定
 * @param param: 0 or 1
 */
View.prototype.blendType = function(param) {
	switch(param) {
		case 0: // 透過処理
			this.gl.blendEquationSeparate(
				this.gl.FUNC_ADD, this.gl.FUNC_ADD);
        	this.gl.blendFuncSeparate(
        		this.gl.ONE, this.gl.ONE_MINUS_SRC_ALPHA, 
        		this.gl.ONE, this.gl.ONE_MINUS_SRC_ALPHA);
			break;
		case 1: // 加算合成
			this.gl.blendFunc(
				this.gl.SRC_ALPHA, 
				this.gl.ONE);
			break;
	}
};	

/**
 * テクスチャの生成
 * @param source: 画像パス
 */
View.prototype.createTexture = function(img, quality) {
	let mipmap = this.gl[quality]
	,   tex    = this.gl.createTexture();

	this.gl.bindTexture(this.gl.TEXTURE_2D, tex);
	this.gl.texImage2D(
		this.gl.TEXTURE_2D, 0, 
		this.gl.RGBA, this.gl.RGBA, 
		this.gl.UNSIGNED_BYTE, img);
	this.gl.texParameteri(
		this.gl.TEXTURE_2D, 
		this.gl.TEXTURE_MAG_FILTER, 
		this.gl.LINEAR);
    this.gl.texParameteri(
    	this.gl.TEXTURE_2D, 
    	this.gl.TEXTURE_MIN_FILTER, mipmap);
    this.gl.generateMipmap(this.gl.TEXTURE_2D);
    this.gl.bindTexture(this.gl.TEXTURE_2D, null);

	return tex;
};

/**
 * 全ての計算を終えた頂点座標の取得
 */
View.prototype.getPosition = function(layer) {
	let position = copy(app_json.layer[layer].init_position);

	// 差分の吸収
	position = this.diffPosition(layer, position);
	// 移動
	position = this.movePosition(layer, position);
	// 回転
	position = this.rotatePosition(layer, position);

	return position;
};

/**
 * 移動量の取得
 */
View.prototype.getMove = function(layer) {
	let move      = copy(app_json.layer[layer].move)
	,   parameter = app_json.layer[layer].parameter
	,   keyframes = app_state.current_keyframes;

	for(let p_name in parameter) {
		let param = parameter[p_name].move
		,   x     = app_state.parameter[p_name].x
		,   y     = app_state.parameter[p_name].y
		,   dire_x, p_x
		,   dire_y, p_y;

		if(param === undefined) continue;

		if(keyframes !== false) {
			let points = app_json.keyframes[keyframes][p_name]
			,   m      = getMiddleVal(points);
			x = m.x;
			y = m.y;
		}

		if(x > 0.5) { // --------------------- right
			dire_x = 1
			p_x    = (x - 0.5) / 0.5;
		} else { // -------------------------- left
			dire_x = 0
			p_x = Math.abs(0.5 - x) / 0.5;
		}

		if(y !== undefined) {
			if(y > 0.5) { // ----------------- bottom
				dire_y = 3
				p_y    = (y - 0.5) / 0.5;
			} else { // ---------------------- top
				dire_y = 2
				p_y    = Math.abs(0.5 - y) / 0.5;
			}
		}

		if(y === undefined) { // ------------------------- 2点パラメータ
			move.x += param[dire_x].x * p_x;
			move.y -= param[dire_x].y * p_x;
		} else { // -------------------------------------- 4点パラメータ
			move.x += param[dire_x].x * p_x;
			move.y -= param[dire_y].y * p_y;
		}
	}

	return move;	
};

/**
 * 回転量の取得
 */
View.prototype.getRotate = function(layer) {
	let rotate    = copy(app_json.layer[layer].rotate)
	,   parameter = app_json.layer[layer].parameter
	,   keyframes = app_state.current_keyframes;

	for(let p_name in parameter) {
		let param = parameter[p_name].rotate;

		if(param === undefined) continue;

		let p_x = app_state.parameter[p_name].x;

		if(keyframes !== false) {
			let points = app_json.keyframes[keyframes][p_name]
			,   m      = getMiddleVal(points);
			p_x = m.x;
		}

		if(p_x > 0.5) { // right
			dire_x = 1
			p_x    = (p_x - 0.5) / 0.5;
		} else {        // left
			dire_x = 0
			p_x = Math.abs(0.5 - p_x) / 0.5;
		}
		rotate += param[dire_x] * p_x;
	}

	return rotate;
};

/**
 * 頂点座標の移動
 */
View.prototype.movePosition = function(layer, position) {
	let move = this.getMove(layer);

	for(let i=0; i < position.length; i+=3) {
		position[i]   += move.x;
		position[i+1] -= move.y;
	}

	return copy(position);
};

/**
 * 差分を吸収した頂点座標
 */
View.prototype.diffPosition = function(layer, position) {
	let parameter = app_json.layer[layer].parameter
	,   keyframes = app_state.current_keyframes;

	for(let p_name in parameter) {
		let param = parameter[p_name].position
		,   type  = app_json.parameter[p_name].type
		,   x     = app_state.parameter[p_name].x
		,   y     = app_state.parameter[p_name].y
		,   dire_x, p_x		,   dire_y, p_y;


		if(param === undefined) continue;

		if(keyframes !== false) {
			let points = app_json.keyframes[keyframes][p_name]
			,   m      = getMiddleVal(points, type);
			x = m.x;
			y = m.y;
		}

		if(x > 0.5) { // --------------------- right
			dire_x = 1
			p_x    = (x - 0.5) / 0.5;
		} else { // -------------------------- left
			dire_x = 0
			p_x = Math.abs(0.5 - x) / 0.5;
		}

		if(y !== undefined) {
			if(y > 0.5) { // ----------------- bottom
				dire_y = 3
				p_y    = (y - 0.5) / 0.5;
			} else { // ---------------------- top
				dire_y = 2
				p_y    = Math.abs(0.5 - y) / 0.5;
			}
		}

		if(y === undefined) { // ------------------------- 2点パラメータ
			for(let i=0; i < param[dire_x].length; i+=3) {
				position[i]   += param[dire_x][i] * p_x;
				position[i+1] += param[dire_x][i+1] * p_x;
			}
		} else { // -------------------------------------- 4点パラメータ
			for(let i=0; i < param[dire_x].length; i+=3) {
				position[i]   += param[dire_x][i] * p_x;
				position[i+1] += param[dire_y][i+1] * p_y;
			}
		}
	}

	return position;
};

/**
 * 頂点座標の回転
 */
View.prototype.rotatePosition = function(layer, position) {
	let rotate = this.getRotate(layer)
	,   x      = app_json.layer[layer].anchor.x
	,   y      = app_json.layer[layer].anchor.y;

	for(let i=0; i < position.length; i+=3) {
		let x2       = position[i]
		,   y2       = position[i+1]
		,   rot      = Math.atan2(y2 - y, x2 - x) * 180 / Math.PI
		,   distance = Math.sqrt((x2 - x) * (x2 - x) + (y2 - y) * (y2 - y));

		rot += rotate;

		let rad = rot * Math.PI / 180
		,   sin = Math.sin(rad)
		,   cos = Math.cos(rad);

		position[i]   = (cos * distance) + x;
		position[i+1] = (sin * distance) + y;
	}

	return position;
};

/**
 * 頂点座標の拡大縮小
 */
View.prototype.scale = function(position) {
	let per_x, per_y;
	if(app_state.position.x < 0.5) // x
		per_x = 5 * ((app_state.position.x - 0.5) / 1);
	else
		per_x = 5 * ((app_state.position.x - 0.5) / 1);
	if(app_state.position.y < 0.5) // y
		per_y = 5 * ((0.5 - app_state.position.y) / 1);
	else
		per_y = 5 * (-(app_state.position.y - 0.5) / 1);
	
	for(let i=0; i < position.length; i+=3) { // 拡大縮小
		position[i]   += per_x;
		position[i]   *= app_state.scale;
		position[i+1] += per_y;
		position[i+1] *= app_state.scale;
	}

	return position;
};

/**
 * 描画
 */
View.prototype.render = function() {
	this.clear();      // 画面クリア
	this.viewMatrix(); // ビュー設定
	this.blendType(0); // ブレンドタイプの設定
	this.navigator.clear();

	for(let key=0; key < app_json.layer.length; key++) {
		let position      = this.getPosition(key)         // 行列
		,   color         = copy(app_json.layer[key].color)
		,   texture_coord = copy(app_json.layer[key].texture_coord)
		,   index         = copy(app_json.layer[key].index);

		let layer         = app_state.current_layer       // レイヤー情報
		,   mesh          = app_json.layer[layer].mesh
		,   show          = app_json.layer[key].show;

		position = this.scale(position); // 拡大縮小

		if(!position) continue;         // 表示確認
		if(show === 'hidden') continue; // 表示するか
		if(key === layer)               // ナビゲータ表示
			this.navigator.render(copy(position), mesh);

		// vbo & iboの生成
	    this.vPosition     = this.createVbo(position);
	    this.vColor        = this.createVbo(color);
		this.vTextureCoord = this.createVbo(texture_coord);
		this.iIndex        = this.createIbo(index);

		// vbo & iboの登録
		this.setAttribute( // 座標情報
			this.vPosition, 
			this.attLocation.position, 
			this.attStride.position);
		this.setAttribute( // 色情報
			this.vColor, 
			this.attLocation.color, 
			this.attStride.color);
		this.setAttribute( // テクスチャ情報
			this.vTextureCoord, 
			this.attLocation.texture, 
			this.attStride.texture);
		
		this.gl.bindTexture( // テクスチャのバインド
			this.gl.TEXTURE_2D, 
			this.texture[app_json.layer[key].name]);

		// ブレンドの有効
		this.gl.enable(this.gl.BLEND);
		
		// uniform変数の登録
		this.gl.uniformMatrix4fv(this.uniLocation.mvpMatrix, false, this.mvp_matrix);
		this.gl.uniform1f(this.uniLocation.vertexAlpha, 1.0);
		this.gl.uniform1i(this.uniLocation.texture, 0);
		this.gl.uniform1i(this.uniLocation.useTexture, true);
		this.gl.bindBuffer(this.gl.ELEMENT_ARRAY_BUFFER, this.iIndex);

		this.gl.drawElements( // 描画登録
			this.gl.TRIANGLES, 
			app_json.layer[key].index.length, 
			this.gl.UNSIGNED_SHORT, 0);
	}
	this.gl.flush(); // 画面表示
};

/**
 * 画面のクリア
 */
View.prototype.clear = function() {
	this.gl.clearColor(0.0, 0.0, 0.0, 0.0);
	this.gl.clearDepth(1.0);
	this.gl.clear(this.gl.COLOR_BUFFER_BIT | this.gl.DEPTH_BUFFER_BIT);
};

/**
 * ビュー＆プロジェクション
 */
View.prototype.viewMatrix = function() {
	this.m.lookAt(
		[0.0, 0.0, this.view_param], 
		[0.0, 0.0, 0.0], 
		[0.0, 1.0, 0.0], this.v_matrix);
	this.m.perspective(
		50, this.webgl_width/this.webgl_height, 0.1, 100, this.p_matrix);
	this.m.multiply(this.p_matrix, this.v_matrix, this.tmp_matrix);
	this.m.multiply(this.tmp_matrix, this.m_matrix, this.mvp_matrix);
};

module.exports = View;

/*******************************************************************
 * 
 * Navigator Class
 * ナビゲータークラス
 * 
 * @param view: Viewオブジェクト
 * @param canvas: canvas要素
 * 
 *******************************************************************/
function Navigator(view, canvas) {
	// view
	this.view = view;
	// canvas
	this.canvas = canvas;
	// ctx
	this.ctx = this.canvas.getContext("2d");

	// event
	this.setHandler();
}

/**
 * イベントハンドラの設置
 */
Navigator.prototype.setHandler = function() {
	this.eventPointer(); // 移動
	//this.eventScale();   // 拡大縮小
	this.eventPolygon(); // ポリゴン変形
	this.eventCollect(); // ポリゴン変形
	this.eventAnchor();  // アンカーポイント移動
	this.eventRotate();  // 回転
	this.eventCubism();  // 曲面
	//this.eventCurve();   // 曲線
	this.eventAtari();   // アタリ
};

/**
 * 移動モード
 */
Navigator.prototype.eventPointer = function() {
	var self = this
	,   down = false;

	/**
	 * mousedown
	 */
	this.canvas.addEventListener('mousedown', function(e) {
		if(app_state.mode !== 'pointer')    // マウスモード
			return;
		else if(app_json.layer.length <= 0) // レイヤーがあるか
			return;
		else if(app_state.current_keyframes !== false)
			return;
		else if(!self.checkRegistration())  // パラメータ登録されているか
			return;

		var rect = this.getBoundingClientRect();
		down = { // マウスの位置を記憶
			x: e.clientX - rect.left,
			y: e.clientY - rect.top
		};
	}, false);

	/**
	 * mousemove
	 */
	window.addEventListener('mousemove', function(e) {
		if(app_state.mode !== 'pointer')    // マウスモード
			return;
		else if(!down)                      // マウスダウンしたか
			return;            
		else if(app_json.layer.length <= 0) // レイヤーがあるか
			return;
		else if(!self.checkRegistration())  // パラメータ登録されているか
			return;

		var layer = app_state.current_layer
		,   parameter = app_state.current_parameter
		,   type = app_json.parameter[parameter].type;
		if(type === 3) // 回転パラメータを弾く 
			return;

		var n = self.checkParameter();
		if(n === false) // 基準パラメータでない
			return;

		var rect = self.canvas.getBoundingClientRect()
		,   x    = (e.clientX-rect.left)
		,   y    = (e.clientY-rect.top);

		// 差分を抽出
		var diff_x = 4.2 * ((x-down.x)/self.view.webgl_width)
		,   diff_y = 4.2 * ((y-down.y)/self.view.webgl_height);

		// マウス位置の更新
		down = { x: x, y: y };

		var tmp_x, tmp_y;
		if(n === 0) { // ------------------------------------- 中心
			app_json.layer[layer].move.x += diff_x;
			app_json.layer[layer].move.y += diff_y;
			tmp_x = app_json.layer[layer].move.x;
			tmp_y = app_json.layer[layer].move.y;
		} else if(type === 2) { // --------------------------- 2点パラメータ
			app_json.layer[layer].parameter[parameter].move[n-1].x += diff_x;
			app_json.layer[layer].parameter[parameter].move[n-1].y -= diff_y;
			tmp_x = app_json.layer[layer].parameter[parameter].move[n-1].x;
			tmp_y = app_json.layer[layer].parameter[parameter].move[n-1].y;
		} else { // ------------------------------------------ 4点パラメータ
			if(n === 1 || n === 2)           // x
				app_json.layer[layer].parameter[parameter].move[n-1].x += diff_x;
			else if(n === 3 || n === 4)      // y
				app_json.layer[layer].parameter[parameter].move[n-1].y -= diff_y;

			tmp_x = app_json.layer[layer].parameter[parameter].move[n-1].x;
			tmp_y = app_json.layer[layer].parameter[parameter].move[n-1].y;
		}

		UI.mode_navigator.emit('pointer', { // モードナビゲータ
			x: tmp_x,
			y: tmp_y
		});

		// 描画
		self.view.render();
	}, false);

	/**
	 * mouseup
	 */
	window.addEventListener('mouseup', function(e) {
		if(down !== false) {
			UI.history.pushHistory(); // 履歴の更新
		}
		UI.mode_navigator.emit('end');
		down = false;
	}, false);
};

/**
 * ポリゴン変形のモード
 */
Navigator.prototype.eventPolygon = function() {
	var self = this
	,   down = false;

	/**
	 * mousedown
	 */
	this.canvas.addEventListener("mousedown", function(e) {
		var num = self.checkParameter();
		if(app_state.mode !== 'polygon')    // マウスモード
			return;
		else if(app_json.layer.length <= 0) // レイヤーがあるか
			return;
		else if(app_state.current_keyframes !== false)
			return;
		else if(!self.checkRegistration())  // パラメータ登録しているか
			return;
		else if(num === false)              // 基準パラメータかチェック
			return;

		var rect = this.getBoundingClientRect()
		,   x = (e.clientX - rect.left)
		,   y = (e.clientY - rect.top)
		,   position = copy(self.decodePosAll(
				self.scale(self.view.getPosition(app_state.current_layer))
			));

		down = self.activePosition(position, x, y); // 選択中の頂点番号
	}, false);

	/**
	 * mousemove
	 */
	this.canvas.addEventListener("mousemove", function(e) {
		if(app_state.mode !== 'polygon')    // マウスモード
			return;              
		else if(app_json.layer.length <= 0) // レイヤーがあるか
			return;
		else if(down === false)             // マウスダウン 
			return;
		else if(!self.checkRegistration())  // パラメータ登録しているか
			return;

		var rect      = this.getBoundingClientRect()
		,   p         = self.scalePos((e.clientX - rect.left), (e.clientY - rect.top))
		,   layer     = app_state.current_layer
		,   parameter = app_state.current_parameter
		,   type      = app_json.parameter[parameter].type
		,   n         = self.checkParameter();
		if(n === false) // 基準パラメータでない
			return;
		if(type === 3)  // 回転パラメータを弾く
			return;

		// 頂点の移動
		var pos  = self.encodePos(p.x, p.y)
		,   move = self.view.getMove(layer)
		,   _x   = app_json.layer[layer].init_position[down*3]
		,   _y   = app_json.layer[layer].init_position[down*3+1];
		pos.x   -= move.x;
		pos.y   += move.y;
		
		if(n === 0) { // ------------------------------------- 中心
			app_json.layer[layer].init_position[down*3]   = pos.x;
			app_json.layer[layer].init_position[down*3+1] = pos.y;
		} else if(type === 2) { // --------------------------- 2点パラメータ
			if(pos.x > _x) var d_x = -(_x - pos.x); // x
			else           var d_x = pos.x - _x;

			if(pos.y > _y) var d_y = -(_y - pos.y); // y
			else           var d_y = pos.y - _y;

			app_json.layer[layer].parameter[parameter].position[n-1][down*3] = d_x;
			app_json.layer[layer].parameter[parameter].position[n-1][down*3+1] = d_y;
		} else { // ------------------------------------------ 4点パラメータ
			if(n === 1 || n === 2) {              // x
				if(pos.x > _x) var d_x = -(_x - pos.x);
				else           var d_x = pos.x - _x; 

				app_json.layer[layer].parameter[parameter].position[n-1][down*3] = d_x;
			} else if(n === 3 || n === 4) {       // y
				if(pos.y > _y) var d_y = -(_y - pos.y);
				else           var d_y = pos.y - _y;

				app_json.layer[layer].parameter[parameter].position[n-1][down*3+1] = d_y;
			}
		}

		// 描画
		self.view.render();
	}, false);

	/**
	 * mouseup
	 */
	window.addEventListener("mouseup", function(e) {
		if(self.checkParameter() !== false && down !== false) {
			UI.history.pushHistory(); // 履歴の更新
		}
		down = false;
	}, false);
};

/**
 * コレクトのモード
 */
Navigator.prototype.eventCollect = function() {
	this.collect_rect = false;
	let self = this
	,   move = false
	,   mode = 'select'
	,   act = [];

	/**
	 * mousedown
	 */
	this.canvas.addEventListener("mousedown", function(e) {
		if(app_state.mode !== 'collect')    // マウスモード
			return;
		else if(app_json.layer.length <= 0) // レイヤーがあるか
			return;
		else if(app_state.current_keyframes !== false)
			return;
		else if(!self.checkRegistration())  // パラメータ登録しているか
			return;

		let rect      = this.getBoundingClientRect()
		,   pos       = self.scalePos(e.clientX - rect.left, e.clientY - rect.top)
		,   p         = self.encodePos(pos.x, pos.y)
		,   layer     = app_state.current_layer
		,   parameter = app_state.current_parameter
		,   type      = app_json.parameter[parameter].type
		,   n         = self.checkParameter();
		if(n === false) // 基準パラメータでない
			return;
		if(type === 3)  // 回転パラメータを弾く
			return;

		if(mode === 'select') // ---------------- select
			self.collect_rect = { x: p.x, y: p.y };
		else if(mode === 'move') { // ----------- move
			if(self.checkRect(self.collect_rect, p.x, p.y))
				move = { x: p.x, y: p.y };
			else {
				mode = 'select';
				act = [];
				self.collect_rect = false;
				self.view.render();
			}
		}
	}, false);

	/**
	 * mousemove
	 */
	this.canvas.addEventListener("mousemove", function(e) {
		if(app_state.mode !== 'collect')    // マウスモード
			return;              
		else if(app_json.layer.length <= 0) // レイヤーがあるか
			return;
		else if(self.collect_rect === false)// マウスダウン 
			return;
		else if(!self.checkRegistration())  // パラメータ登録しているか
			return;

		let rect      = self.canvas.getBoundingClientRect()
		,   pos       = self.scalePos((e.clientX - rect.left), (e.clientY - rect.top))
		,   p         = self.encodePos(pos.x, pos.y)
		,   layer     = app_state.current_layer
		,   parameter = app_state.current_parameter
		,   type      = app_json.parameter[parameter].type
		,   n         = self.checkParameter();
		if(n === false) // 基準パラメータでない
			return;
		if(type === 3)  // 回転パラメータを弾く
			return;

		if(mode === 'select') { // ------------------------- select
			self.collect_rect._x = p.x;
			self.collect_rect._y = p.y;

			self.view.render();
		} else if(mode === 'move' && move !== false) { // -- move
			var add_x = p.x - move.x
			,   add_y = p.y - move.y;
			move.x    = p.x;
			move.y    = p.y;
			self.collect_rect.x  += add_x; 
			self.collect_rect._x += add_x;
			self.collect_rect.y  += add_y;
			self.collect_rect._y += add_y;

			if(type === 2) { // ----------------------------------- 2点パラメータ
				for(let i=0; i < act.length; i++) {
					app_json.layer[layer].parameter[parameter].position[n-1][act[i]] += add_x;
					app_json.layer[layer].parameter[parameter].position[n-1][act[i]+1] += add_y;
				}
			} else { // ------------------------------------------- 4点パラメータ
				if(n === 1 || n === 2) {              // x
					for(let i=0; i < act.length; i++) {
						app_json.layer[layer].parameter[parameter].position[n-1][act[i]] += add_x;
					}
				} else if(n === 3 || n === 4) {       // y
					for(let i=0; i < act.length; i++) {
						app_json.layer[layer].parameter[parameter].position[n-1][act[i]+1] += add_y;
					}
				}
			}

			self.view.render();
		}
	}, false);

	/**
	 * mouseup
	 */
	window.addEventListener("mouseup", function(e) {
		if(mode === 'select' && self.collect_rect !== false) {
			var pos = copy(self.view.getPosition(app_state.current_layer));
			act = self.activeCollect(pos);
			mode = 'move';
		} else if(mode === 'move') {
			if(self.checkParameter() !== false && move !== false) {
				UI.history.pushHistory(); // 履歴の更新
			}
			move = false;
		}
	}, false);
};

/**
 * アンカーポイント変更のモード
 */
Navigator.prototype.eventAnchor = function() {
	let self = this
	,   down = false;

	/**
	 * mousedown
	 */
	this.canvas.addEventListener("mousedown", function(e) {
		if(app_state.mode !== 'anchor')     // マウスモード
			return;
		else if(app_state.current_keyframes !== false)
			return;
		else if(app_json.layer.length <= 0) // レイヤーがあるか
			return;

		down = true;
	}, false);

	/**
	 * mousemove
	 */ 
	this.canvas.addEventListener("mousemove", function(e) {
		if(app_state.mode !== 'anchor')     // マウスモード
			return;              
		else if(app_json.layer.length <= 0) // レイヤーがあるか
			return;
		else if(down === false)             // マウスダウン 
			return;
		
		let rect  = this.getBoundingClientRect()
		,   x     = e.clientX - rect.left
		,   y     = e.clientY - rect.top
		,   layer = app_state.current_layer
		,   pos   = self.scalePos(x, y)
		,   p     = self.encodePos(pos.x, pos.y);

		app_json.layer[layer].anchor.x = p.x;
		app_json.layer[layer].anchor.y = p.y;

		UI.mode_navigator.emit('anchor', {
			x: app_json.layer[layer].anchor.x,
			y: app_json.layer[layer].anchor.y
		});

		self.view.render(); // 描画
	}, false);

	/**
	 * mouseup
	 */
	window.addEventListener("mouseup", function(e) {
		if(down !== false) {
			UI.history.pushHistory(); // 履歴の更新
		}
		UI.mode_navigator.emit('end');
		down = false;
	}, false);
};

/**
 * 回転のモード
 */
Navigator.prototype.eventRotate = function() {
	let self = this
	,   down = false;

	/**
	 * mousedown
	 */
	this.canvas.addEventListener('mousedown', function(e) {
		if(app_state.mode !== 'rotate')    // マウスモード
			return;
		else if(app_json.layer.length <= 0) // レイヤーがあるか
			return;
		else if(app_state.current_keyframes !== false)
			return;
		else if(!self.checkRegistration())  // パラメータ登録しているか
			return;

		let rect      = this.getBoundingClientRect()
		,   x         = e.clientX - rect.left
		,   y         = e.clientY - rect.top
		,   layer     = app_state.current_layer
		,   parameter = app_state.current_parameter
		,   type      = app_json.parameter[parameter].type
		,   n         = self.checkParameter();
		
		if(n === false)               // 基準パラメータでない
			return;
		if(type === 2 || type === 4)  // 回転パラメータを弾く
			return;

		down = { x: x, y: y };
	}, false);

	/**
	 * mousemove
	 */
	this.canvas.addEventListener('mousemove', function(e) {
		if(app_state.mode !== 'rotate')     // マウスモード
			return;              
		else if(app_json.layer.length <= 0) // レイヤーがあるか
			return;
		else if(down === false)             // マウスダウン 
			return;

		let rect      = this.getBoundingClientRect()
		,   x         = e.clientX - rect.left
		,   y         = e.clientY - rect.top
		,   layer     = app_state.current_layer
		,   parameter = app_state.current_parameter
		,   type      = app_json.parameter[parameter].type
		,   n         = self.checkParameter();

		let rot = yuki540.diff(down.x, x);

		app_json.layer[layer].parameter[parameter].rotate[n-1] = rot;

		UI.mode_navigator.emit('rotate', rot);

		self.view.render();
	}, false);

	/**
	 * mouseup
	 */
	window.addEventListener('mouseup', function(e) {
		if(down !== false) {
			UI.history.pushHistory(); // 履歴の更新
		}
		UI.mode_navigator.emit('end');
		down = false;
	}, false);
};

/**
 * 曲面のモード
 */
Navigator.prototype.eventCubism = function() {
	let self = this
	,   down = false;

	/**
	 * mousedown
	 */
	this.canvas.addEventListener('mousedown', function(e) {
		if(app_state.mode !== 'cubism')     // マウスモード
			return;
		else if(app_state.current_keyframes !== false)
			return;
		else if(app_json.layer.length <= 0) // レイヤーがあるか
			return;

		let rect = this.getBoundingClientRect()
		,   x    = e.clientX - rect.left
		,   y    = e.clientY - rect.top;
		down = { x: x, y: y };
	}, false);

	/**
	 * mousemove
	 */
	this.canvas.addEventListener('mousemove', function(e) {
		if(app_state.mode !== 'cubism')     // マウスモード
			return;
		else if(app_json.layer.length <= 0) // レイヤーがあるか
			return;
		else if(down === false)             // マウスダウン
			return;
		else if(!self.checkRegistration())  // パラメータ登録されているか
			return;

		let n    = self.checkParameter()
		,   rect = this.getBoundingClientRect()
		,   x    = e.clientX - rect.left
		,   y    = e.clientY - rect.top
		,   layer     = app_state.current_layer
		,   parameter = app_state.current_parameter
		,   type      = app_json.parameter[parameter].type;

		if(n === 0 || n === false) // 基準点以外を弾く
			return;

		if(x > down.x) // 差分を抽出         
			var diff_x = x - down.x;
		else
			var diff_x = -(down.x - x);
		if(y > down.y)       
			var diff_y = y - down.y;
		else
			var diff_y = -(down.y - y);
		
		diff_x = 5 * (diff_x / (self.view.width * app_state.scale));
		diff_y = 5 * (diff_y / (self.view.height * app_state.scale));
		diff_x *= -1;
		diff_y *= -1;

		if(type === 2) { // --------------------------- 2点パラメータ
			let pos = self.getCubism(diff_x, diff_y);
			app_json.layer[layer].parameter[parameter].position[n-1] = pos;
		} else if(type === 4) { // -------------------- 4点パラメータ
			if(n === 1 || n === 2) {              // x
				let pos = self.getCubism(diff_x, 0);
				app_json.layer[layer].parameter[parameter].position[n-1] = pos;
			} else if(n === 3 || n === 4) {       // y
				let pos = self.getCubism(0, diff_y);
				app_json.layer[layer].parameter[parameter].position[n-1] = pos;
			}
		}

		UI.mode_navigator.emit('cubism', {
			x: diff_x,
			y: diff_y
		});

		self.view.render();
	}, false);

	/**
	 * mouseup
	 */
	window.addEventListener('mouseup', function(e) {
		if(self.checkParameter() !== false && down !== false) {
			UI.history.pushHistory(); // 履歴の更新
		}
		UI.mode_navigator.emit('end');
		down = false;
	}, false);
};

/**
 * アタリのモード
 */
Navigator.prototype.eventAtari = function() {
	let self = this
	,   down = false;

	/**
	 * mousedown
	 */
	this.canvas.addEventListener('mousedown', function(e) {
		if(app_state.mode !== 'atari')      // マウスモード
			return;
		else if(app_state.current_keyframes !== false)
			return;
		else if(app_json.layer.length <= 0) // レイヤーがあるか
			return;

		down = true;
	}, false);

	/**
	 * mousemove
	 */
	this.canvas.addEventListener('mousemove', function(e) {
		if(app_state.mode !== 'atari')      // マウスモード
			return;
		else if(app_json.layer.length <= 0) // レイヤーがあるか
			return;
		else if(down === false)             // マウスダウン
			return;

		let rect   = this.getBoundingClientRect()
		,   x      = e.clientX - rect.left
		,   y      = e.clientY - rect.top
		,   layer  = app_state.current_layer
		,   width  = self.view.width
		,   height = self.view.height
		,   pos    = self.scalePos(x, y)
		,   p      = self.encodePos(pos.x, pos.y);

		if(self.checkCenter(layer, p.x, p.y)) { // 有効エリアか
			app_json.layer[layer].center.x = p.x;
			app_json.layer[layer].center.y = p.y;
			UI.mode_navigator.emit('atari', {
				x: p.x,
				y: p.y
			});
		}
		
		self.view.render(); // 描画
	}, false);

	/**
	 * mouseup
	 */
	window.addEventListener('mouseup', function(e) {
		if(down !== false) {
			UI.history.pushHistory(); // 履歴の更新
		}
		UI.mode_navigator.emit('end');
		down = false;
	}, false);
};

/**
 * 中心設定の有効エリア内かチェック
 */
Navigator.prototype.checkCenter = function(layer, x, y) {
	// レイヤー情報
	let mesh     = app_json.layer[layer].mesh
	,   position = copy(app_json.layer[layer].init_position);

	// 4点
	let p1 = 0
	,   p2 = (((mesh + 1) * 3) * mesh) + (mesh * 3)
	,   x1 = position[p1],  y1 = position[p1+1]
	,   x2 = position[p2],  y2 = position[p2+1];

	return yuki540.between(x1, x2, x) && yuki540.between(y2, y1, y);
};

/**
 * 曲面の生成
 */
Navigator.prototype.getCubism = function(diff_x, diff_y) {
	var layer    = app_state.current_layer
	,   position = copy(app_json.layer[layer].init_position)
	,   mesh     = app_json.layer[layer].mesh
	,   pos      = new Array(position.length)
	,   center_x = app_json.layer[layer].center.x
	,   center_y = app_json.layer[layer].center.y;

	pos = yuki540.fill(pos, 0); // 初期化

	for(let y=0; y <= mesh; y++) { // -------------- y
		for(let x=0; x <= mesh; x++) {
			let num = (x * 3) + (((mesh + 1) * 3) * y)
			,   v   = position[num];

			if(x === 0) {
				var first_x = position[num]
				,   last_x  = position[(mesh * 3) + (((mesh + 1) * 3) * y)]
				,   _x      = Math.abs(yuki540.diff(center_x, yuki540.near(center_x, [first_x, last_x])))
				,   min     = center_x - _x
				,   max     = center_x + _x;
			}

			let per = yuki540.per(min, max, v);
			if(per > 1)       per = 1;
			else if(per < 0)  per = 0;

			let r   = 180 * (1 - per)
			,   sin = Math.sin(r * Math.PI / 180);

			pos[num+1] = sin * diff_y;
		}
	}

	for(let x=0; x <= mesh; x++) { // -------------- x
		for(let y=0; y <= mesh; y++) {
			let num = (x * 3) + (((mesh + 1) * 3) * y)
			,   v   = position[num+1];

			if(y === 0) {
				var first_y = position[num+1]
				,   last_y  = position[((x * 3) + (((mesh + 1) * 3) * mesh)) + 1]
				,   _y      = Math.abs(yuki540.diff(center_y, yuki540.near(center_y, [first_y, last_y])))
				,   min     = center_y + _y
				,   max     = center_y - _y;
			}

			let per = yuki540.per(min, max, v);
			if(per > 1)       per = 1;
			else if(per < 0)  per = 0;

			let r   = (180 * per) + 90
			,   cos = Math.cos(r * Math.PI / 180);

			pos[num] = cos * diff_x;
		}
	}

	return copy(pos);
};

/**
 * 基準パラメータかチェック
 */
Navigator.prototype.checkParameter = function() {
	let parameter = app_state.current_parameter
	,   type      = app_json.parameter[parameter].type
	,   p         = app_state.parameter[parameter]
	,   n         = false;

	if(type === 2 || type === 3) { // ----------- 2, 3点パラメータ
		if(p.x === 0.5)      n = 0;
		else if(p.x === 0.0) n = 1;
		else if(p.x === 1.0) n = 2;
	} else { // --------------------------------- 4点パラメータ
		if(p.x === 0.5 && p.y === 0.5)      n = 0;
		else if(p.x === 0.0 && p.y === 0.5) n = 1;
		else if(p.x === 1.0 && p.y === 0.5) n = 2;
		else if(p.x === 0.5 && p.y === 0.0) n = 3;
		else if(p.x === 0.5 && p.y === 1.0) n = 4;
	}

	return n;
};

/**
 * パラメータ登録されているかチェック
 */
Navigator.prototype.checkRegistration = function() {
	let  layer     = app_state.current_layer
	,    parameter = app_state.current_parameter
	,    flg       = false;

	for(let p_name in app_json.layer[layer].parameter) {
		if(parameter === p_name) {
			flg = true; 
			break;
		} else flg = false;
	}
	return flg;
};

/**
 * 4角形の内側かチェック
 */
Navigator.prototype.checkRect = function(down, x, y) {
	let x1, x2, y1, y2;
	if(down.x > down._x)  // 入れ替え
		x1 = down._x, x2 = down.x;
	else
		x1 = down.x,  x2 = down._x;
	
	if(down.y > down._y) 
		y1 = down._y, y2 = down.y;
	else
		y1 = down.y,  y2 = down._y;

	if(x1 <= x && x2 >= x && y1 <= y && y2 >= y) 
		return true;
	else
		return false;
};

/**
 * 拡大縮小処理
 */
Navigator.prototype.scale = function(tmp_position) {
	let per_x, per_y;
	if(app_state.position.x < 0.5) // x
		per_x = 5 * ((app_state.position.x - 0.5) / 1);
	else
		per_x = 5 * ((app_state.position.x - 0.5) / 1);
	if(app_state.position.y < 0.5) // y
		per_y = 5 * ((0.5 - app_state.position.y) / 1);
	else
		per_y = 5 * (-(app_state.position.y - 0.5) / 1);

	let position = copy(tmp_position);
	for(let i=0; i < position.length; i+=3) {
		position[i]   += per_x;
		position[i]   *= app_state.scale;
		position[i+1] += per_y;
		position[i+1] *= app_state.scale;
	}

	return position;
};

/**
 * マウス位置の拡大縮小
 */
Navigator.prototype.scalePos = function(x, y) {
	let per_x, per_y;
	if(app_state.position.x < 0.5) // x
		per_x = Math.abs((app_state.position.x - 0.5) / 1);
	else
		per_x = -((app_state.position.x - 0.5) / 1);
	if(app_state.position.y < 0.5) // y
		per_y = ((0.5 - app_state.position.y) / 1);
	else
		per_y = (-(app_state.position.y - 0.5) / 1);

	per_x = per_x * this.view.webgl_width * app_state.scale;
	per_y = per_y * this.view.webgl_height * app_state.scale;

	let width  = this.view.webgl_width * app_state.scale
	,   height = this.view.webgl_height * app_state.scale
	,   diff_x = (width - this.view.webgl_width) / 2
	,   diff_y = (height - this.view.webgl_height) / 2
	,   p_x    = x + diff_x + per_x
	,   p_y    = y + diff_y + per_y;

	p_x = ((p_x - this.view.webgl_x) / width);
	p_y = ((p_y - this.view.webgl_y) / height);

	return { x: p_x, y: p_y };
};

/**
 * 比率の吸収
 */
Navigator.prototype.margeScale = function(x, y) {
	let scale  = app_state.scale
	,   width  = this.view.webgl_width * scale
	,   height = this.view.webgl_height * scale
	,   per_x, per_y;

	if(app_state.position.x < 0.5) // x
		per_x = Math.abs((app_state.position.x - 0.5) / 1);
	else
		per_x = -((app_state.position.x - 0.5) / 1);
	if(app_state.position.y < 0.5) // y
		per_y = ((0.5 - app_state.position.y) / 1);
	else
		per_y = (-(app_state.position.y - 0.5) / 1);

	let diff_x = 5 * per_x * scale
	,   diff_y = 5 * per_y * scale

	x *= scale,  y *= scale;
	x -= diff_x, y += diff_y;

	return { x: x, y: y };
};

/**
 * ポイントがアクティブかどうか
 * @param pos: 頂点座標の配列
 * @param x: x座標
 * @param y: y座標
 */
Navigator.prototype.activePosition = function(pos, x, y) {
	for(let i=n=0; i < pos.length; i+=3,n++) {
		if((pos[i] - 5) <= x && (pos[i] + 5) >= x &&
			(pos[i+1] - 5) <= y && (pos[i+1] + 5) >= y) {
			return n;
		}
	}

	return false;
};

/**
 * 選択範囲のポイントを取得
 */
Navigator.prototype.activeCollect = function(position) {
	let x, _x, y, _y;
	if(this.collect_rect.x > this.collect_rect._x) {
		_x = this.collect_rect.x;
		x  = this.collect_rect._x;
	} else {
		x  = this.collect_rect.x;
		_x = this.collect_rect._x;
	}
	if(this.collect_rect.y > this.collect_rect._y) {
		_y = this.collect_rect.y;
		y  = this.collect_rect._y;
	} else {
		y  = this.collect_rect.y;
		_y = this.collect_rect._y;
	}

	let act = [];
	for(let i=0; i < position.length; i+=3) {
		if(x <= position[i] && _x >= position[i] &&
			y <= position[i+1] && _y >= position[i+1]) {
			act.push(i);
		}
	}

	return act;
};

/**
 * 画面のクリア
 */
Navigator.prototype.clear = function() {
	this.ctx.clearRect(
		0, 0, 
		this.view.width, this.view.height);
};

/**
 * メッシュ＆頂点の描画
 * @param tmp_position: 頂点座標の配列
 */
Navigator.prototype.render = function(tmp_position, mesh) {
	this.clear(); // 画面クリア

	let position = copy(tmp_position);
	if(app_state.mode === 'preview')         // preview
		return;
	else if(app_state.mode === 'pointer')    // pointer
		this.renderPointer(position);
	else if(app_state.mode === 'polygon')    // polygon
		this.renderPolygon(position, mesh);
	else if(app_state.mode === 'collect')    // cubism
		this.renderCollect(position);
	else if(app_state.mode === 'anchor')     // anchor
		this.renderAnchor(position);
	else if(app_state.mode === 'rotate')     // rotate
		this.renderRotate(position);
	else if(app_state.mode === 'cubism')     // cubism
		this.renderCubism(position, mesh);
	else if(app_state.mode === 'atari')      // atari
		this.renderAtari(position);
};

/**
 * ナビゲータの描画（pointer）
 */
Navigator.prototype.renderPointer = function(position) {

};

/**
 * ナビゲータの描画（polygon）
 */
Navigator.prototype.renderPolygon = function(tmp_position, mesh) {
	let position = copy(tmp_position);
	for(let i=0; i < mesh; i++) {
		for(let n=0; n < mesh; n++) {
			var x = (n * 3) + ((mesh + 1) * 3 * i);
			let pos1 = this.decodePos( // 1
				position[x], 
				position[x+1]);
			let pos2 = this.decodePos( // 2
				position[x+3], 
				position[x+4]);
			let pos3 = this.decodePos( // 3
				position[x+((mesh+1)*3)], 
				position[x+(((mesh+1)*3)+1)]);
			this.drawLine3(pos1, pos2, pos3);

			if((i+1) === mesh) {
				let u_p1 = (n * 3) + ((mesh + 1) * 3 * (i + 1));
				p1 = this.decodePos(position[u_p1], position[u_p1+1]);
				p2 = this.decodePos(position[u_p1+3], position[u_p1+4]);
				this.drawLine2(p1, p2);	
			}
		}
		let r_p1 = (mesh * 3) + (((mesh + 1) * 3) * i);
		r_p1 = this.decodePos(position[r_p1], position[r_p1+1]);
		let r_p2 = (mesh * 3) + (((mesh + 1) * 3) * (i + 1));
		r_p2 = this.decodePos(position[r_p2], position[r_p2+1]);
		this.drawLine2(r_p1, r_p2);
	}
	for(let i=0; i < position.length; i+=3) {  // 頂点描画
		let pos = this.decodePos(position[i], position[i+1]);
		this.drawVertex(pos.x - 3, pos.y - 3);
	}
};

/**
 * ナビゲータの描画（anchor）
 */
Navigator.prototype.renderAnchor = function() {
	var layer  = app_state.current_layer
	,   anchor = app_json.layer[layer].anchor
	,   pos    = this.margeScale(anchor.x, anchor.y)
	,   p      = this.decodePos(pos.x, pos.y)
	,   x      = pos.x.toFixed(2)
	,   y      = pos.y.toFixed(2);
	
	this.drawAnchor(p.x, p.y);
};

/**
 * ナビゲータの描画（rotate）
 */
Navigator.prototype.renderRotate = function() {
	var layer  = app_state.current_layer
	,   rot    = this.view.getRotate(layer)
	,   rotate = -1 * (rot * Math.PI / 180)
	,   anchor = app_json.layer[layer].anchor
	,   pos    = this.margeScale(anchor.x, anchor.y)
	,   p      = this.decodePos(pos.x, pos.y)
	,   x      = pos.x.toFixed(2)
	,   y      = pos.y.toFixed(2);
	
	this.drawRotate(p.x, p.y);
};

/**
 * ナビゲータの描画（collect）
 */
Navigator.prototype.renderCollect = function(tmp_position) {
	if(this.collect_rect !== false) {
		let scale = app_state.scale
		,   _p1   = this.margeScale(this.collect_rect.x, this.collect_rect.y)
		,   _p2   = this.margeScale(this.collect_rect._x, this.collect_rect._y)
		,   p1    = this.decodePos(_p1.x, _p1.y)
		,   p2    = this.decodePos(_p2.x, _p2.y);

		this.drawRect(p1.x, p1.y, p2.x, p2.y);
	}

	let position = copy(tmp_position);
	for(let i=0; i < position.length; i+=3) {  // 頂点描画
		let pos = this.decodePos(position[i], position[i+1]);
		this.drawVertex(pos.x - 3, pos.y - 3);
	}
};

/**
 * ナビゲータの描画（cubism）
 */
Navigator.prototype.renderCubism = function(tmp_position, mesh) {
	let position      = copy(tmp_position)
	,   layer         = app_state.current_layer
	,   _position     = copy(app_json.layer[layer].init_position)
	,   init_position = this.view.scale(_position);

	this.drawCubsim(init_position, mesh, '#ccc'); // 原型
	this.drawCubsim(position, mesh, '#ff0000');   // 変形後
};

/**
 * ナビゲータの描画（center）
 */
Navigator.prototype.renderAtari = function(tmp_position) {
	// レイヤー情報
	let position = copy(tmp_position)
	,   layer    = app_state.current_layer
	,   mesh     = app_json.layer[layer].mesh
	,   center   = app_json.layer[layer].center
	,   p        = this.margeScale(center.x, center.y)
	,   c        = this.decodePos(p.x, p.y)
	,   x        = center.x.toFixed(2)
	,   y        = center.y.toFixed(2);

	// 開始点・最終点
	let p1   = 0
	,   p2   = (((mesh + 1) * 3) * mesh) + (mesh * 3)
	,   pos1 = this.decodePos(position[p1], position[p1+1])
	,   pos2 = this.decodePos(position[p2], position[p2+1]);

	this.drawRect(pos1.x, pos1.y, pos2.x, pos2.y, 'rgba(0,120,255,0.2)');
	this.drawAtari(c.x, c.y);
};

/**
 * アンカーポイントの描画
 */
Navigator.prototype.drawAnchor = function(x, y) {
	let color = '#ff0033';

	this.drawLine2({ // 横線
		x: x - 50, y: y	
	}, {
		x: x + 50, y: y
	}, color);

	this.drawLine2({ // 縦線
		x: x,      y: y - 50	
	}, {
		x: x,      y: y + 50
	}, color);

	this.drawArc(x, y, 3); // 円
};

/**
 * 回転の描画
 */
Navigator.prototype.drawRotate = function(x, y) {
	this.drawArcLine(x, y, 50);  // 円
	this.drawLine2({             // 線
		x: x, y: y
	}, { 
		x: x, y: y - 150,
	} , '#ff0000');            
	this.drawArc(x, y, 3);       // 円
	this.drawArc(x, y - 150, 3); // 円
};

/**
 * キュビズムの描画
 */
Navigator.prototype.drawCubsim = function(position, mesh, color) {
	for(let y=0; y <= mesh; y++) { // 横線
		for(let x=0; x < mesh; x++) {
			let n1 = (x * 3) + (((mesh + 1) * 3) * y)
			,   n2 = n1 + 3
			,   p1 = this.decodePos(position[n1], position[n1+1])
			,   p2 = this.decodePos(position[n2], position[n2+1]);

			this.drawLine2(p1, p2, color);
		}
	}
	for(let x=0; x <= mesh; x++) { // 縦線
		for(let y=0; y < mesh; y++) {
			let n1 = (x * 3) + (((mesh + 1) * 3) * y)
			,   n2 = n1 + ((mesh + 1) * 3)
			,   p1 = this.decodePos(position[n1], position[n1+1])
			,   p2 = this.decodePos(position[n2], position[n2+1]);

			this.drawLine2(p1, p2, color);
		}
	}
};

/**
 * アタリの描画
 */
Navigator.prototype.drawAtari = function(x, y) {
	let color = '#ff0033';

	this.drawLine2({ // 横線
		x: x - 100, y: y	
	}, {
		x: x + 100, y: y
	}, color);

	this.drawLine2({ // 縦線
		x: x,       y: y - 100	
	}, {
		x: x,       y: y + 100
	}, color);
};

/**
 * 4角形の描画
 */
Navigator.prototype.drawRect = function(x, y, _x, _y, color) {
	let w, h;
	if(_x > x) w = _x - x;    // 幅
	else       w = -(x - _x);

	if(_y > y) h = _y - y;    // 高さ
	else       h = -(y - _y);

	if(color === undefined)   // 標準色
		color = 'rgba(0,120,255,0.5)';

	this.ctx.beginPath();
	this.ctx.fillStyle = color;
	this.ctx.fillRect(x, y, w, h);
	this.ctx.closePath();
};

/**
 * 円の描画
 */
Navigator.prototype.drawArc = function(x, y, r) {
	this.ctx.beginPath();
	this.ctx.strokeStyle = '#000';
	this.ctx.fillStyle   = '#ff0000';
	this.ctx.arc(x, y, r, 0, 360 * Math.PI / 180, false);
	this.ctx.fill();
	this.ctx.stroke();
	this.ctx.closePath();
};

/**
 * 円の描画
 */
Navigator.prototype.drawArcLine = function(x, y, r) {
	this.ctx.beginPath();
	this.ctx.strokeStyle = '#ff0000';
	this.ctx.arc(x, y, r, 0, 360 * Math.PI / 180, false);
	this.ctx.stroke();
	this.ctx.closePath();
};

/**
 * 線画の描画2
 */
Navigator.prototype.drawLine2 = function(pos1, pos2, color) {
	if(color === undefined) // 標準色
		color = '#aaa';

	this.ctx.beginPath();
	this.ctx.strokeStyle = color;
	this.ctx.moveTo(pos1.x, pos1.y);
	this.ctx.lineTo(pos2.x, pos2.y);
	this.ctx.closePath();
	this.ctx.stroke();
};

/**
 * 線画の描画3
 */
Navigator.prototype.drawLine3 = function(pos1, pos2, pos3, color) {
	if(color === undefined) // 標準色
		color = '#aaa';

	this.ctx.beginPath();
	this.ctx.strokeStyle = color;
	this.ctx.moveTo(pos1.x, pos1.y);
	this.ctx.lineTo(pos2.x, pos2.y);
	this.ctx.lineTo(pos3.x, pos3.y);
	this.ctx.lineTo(pos1.x, pos1.y);
	this.ctx.closePath();
	this.ctx.stroke();
};

/**
 * 頂点描画
 * @param x: x座標
 * @param y: y座標
 */
Navigator.prototype.drawVertex = function(x, y, color) {
	if(color === undefined) // 標準色
		color = '#fff'; 

	this.ctx.beginPath();
	this.ctx.fillStyle = color;
	this.ctx.strokeStyle = "#000";
	this.ctx.rect(x, y, 6, 6);
	this.ctx.fill();
	this.ctx.stroke();
	this.ctx.closePath();	
};

/**
 * 位置情報の変換
 * @param x: x座標
 * @param y: y座標
 * @return x座標・y座標のハッシュ
 */
Navigator.prototype.encodePos = function(x, y) {
	x = 5 * x;
	y = 5 * y;
	x = x - 2.5;
	y = (y - 2.5) * -1;

	return { x: x, y: y };
};

/**
 * 全位置情報の変換
 */
Navigator.prototype.encodePosAll = function(tmp_pos) {
	let pos     = copy(tmp_pos)
	,   new_pos = [];

	for(let i=0; i < pos.length; i+=3) {
		let p = this.encodePos(pos[i], pos[i+1]);
		new_pos.push(p.x); 
		new_pos.push(p.y); 
		new_pos.push(pos[i+2]);
	}

	return new_pos;
};

/**
 * 位置情報の逆変換
 * @param x: x座標
 * @param y: y座標
 * @return x座標・y座標のハッシュ
 */
Navigator.prototype.decodePos = function(x, y) {
	x = (x + 2.5) / 5;
	y = 1 - ((y + 2.5) / 5);

	let width  = this.view.webgl_width
	,   height = this.view.webgl_height;

	x = width * x + this.view.webgl_x;
	y = height * y + this.view.webgl_y;

	return {x: x, y: y};
};

/**
 * 全位置情報の逆変換
 */
Navigator.prototype.decodePosAll = function(tmp_pos) {
	let pos     = copy(tmp_pos)
	,   new_pos = [];

	for(let i=0; i < pos.length; i+=3) {
		let p = this.decodePos(pos[i], pos[i+1]);
		new_pos.push(p.x); 
		new_pos.push(p.y); 
		new_pos.push(pos[i+2]);
	}

	return new_pos;
};

/**
 * matIV
 */
function matIV() {
	this.create = function(){
		return new Float32Array(16);
	};
	this.identity = function(dest){
		dest[0]  = 1; dest[1]  = 0; dest[2]  = 0; dest[3]  = 0;
		dest[4]  = 0; dest[5]  = 1; dest[6]  = 0; dest[7]  = 0;
		dest[8]  = 0; dest[9]  = 0; dest[10] = 1; dest[11] = 0;
		dest[12] = 0; dest[13] = 0; dest[14] = 0; dest[15] = 1;
		return dest;
	};
	this.multiply = function(mat1, mat2, dest){
		var a = mat1[0],  b = mat1[1],  c = mat1[2],  d = mat1[3],
			e = mat1[4],  f = mat1[5],  g = mat1[6],  h = mat1[7],
			i = mat1[8],  j = mat1[9],  k = mat1[10], l = mat1[11],
			m = mat1[12], n = mat1[13], o = mat1[14], p = mat1[15],
			A = mat2[0],  B = mat2[1],  C = mat2[2],  D = mat2[3],
			E = mat2[4],  F = mat2[5],  G = mat2[6],  H = mat2[7],
			I = mat2[8],  J = mat2[9],  K = mat2[10], L = mat2[11],
			M = mat2[12], N = mat2[13], O = mat2[14], P = mat2[15];
		dest[0] = A * a + B * e + C * i + D * m;
		dest[1] = A * b + B * f + C * j + D * n;
		dest[2] = A * c + B * g + C * k + D * o;
		dest[3] = A * d + B * h + C * l + D * p;
		dest[4] = E * a + F * e + G * i + H * m;
		dest[5] = E * b + F * f + G * j + H * n;
		dest[6] = E * c + F * g + G * k + H * o;
		dest[7] = E * d + F * h + G * l + H * p;
		dest[8] = I * a + J * e + K * i + L * m;
		dest[9] = I * b + J * f + K * j + L * n;
		dest[10] = I * c + J * g + K * k + L * o;
		dest[11] = I * d + J * h + K * l + L * p;
		dest[12] = M * a + N * e + O * i + P * m;
		dest[13] = M * b + N * f + O * j + P * n;
		dest[14] = M * c + N * g + O * k + P * o;
		dest[15] = M * d + N * h + O * l + P * p;
		return dest;
	};
	this.scale = function(mat, vec, dest){
		dest[0]  = mat[0]  * vec[0];
		dest[1]  = mat[1]  * vec[0];
		dest[2]  = mat[2]  * vec[0];
		dest[3]  = mat[3]  * vec[0];
		dest[4]  = mat[4]  * vec[1];
		dest[5]  = mat[5]  * vec[1];
		dest[6]  = mat[6]  * vec[1];
		dest[7]  = mat[7]  * vec[1];
		dest[8]  = mat[8]  * vec[2];
		dest[9]  = mat[9]  * vec[2];
		dest[10] = mat[10] * vec[2];
		dest[11] = mat[11] * vec[2];
		dest[12] = mat[12];
		dest[13] = mat[13];
		dest[14] = mat[14];
		dest[15] = mat[15];
		return dest;
	};
	this.translate = function(mat, vec, dest){
		dest[0] = mat[0]; dest[1] = mat[1]; dest[2]  = mat[2];  dest[3]  = mat[3];
		dest[4] = mat[4]; dest[5] = mat[5]; dest[6]  = mat[6];  dest[7]  = mat[7];
		dest[8] = mat[8]; dest[9] = mat[9]; dest[10] = mat[10]; dest[11] = mat[11];
		dest[12] = mat[0] * vec[0] + mat[4] * vec[1] + mat[8]  * vec[2] + mat[12];
		dest[13] = mat[1] * vec[0] + mat[5] * vec[1] + mat[9]  * vec[2] + mat[13];
		dest[14] = mat[2] * vec[0] + mat[6] * vec[1] + mat[10] * vec[2] + mat[14];
		dest[15] = mat[3] * vec[0] + mat[7] * vec[1] + mat[11] * vec[2] + mat[15];
		return dest;
	};
	this.rotate = function(mat, angle, axis, dest){
		var sq = Math.sqrt(axis[0] * axis[0] + axis[1] * axis[1] + axis[2] * axis[2]);
		if(!sq){return null;}
		var a = axis[0], b = axis[1], c = axis[2];
		if(sq != 1){sq = 1 / sq; a *= sq; b *= sq; c *= sq;}
		var d = Math.sin(angle), e = Math.cos(angle), f = 1 - e,
			g = mat[0],  h = mat[1], i = mat[2],  j = mat[3],
			k = mat[4],  l = mat[5], m = mat[6],  n = mat[7],
			o = mat[8],  p = mat[9], q = mat[10], r = mat[11],
			s = a * a * f + e,
			t = b * a * f + c * d,
			u = c * a * f - b * d,
			v = a * b * f - c * d,
			w = b * b * f + e,
			x = c * b * f + a * d,
			y = a * c * f + b * d,
			z = b * c * f - a * d,
			A = c * c * f + e;
		if(angle){
			if(mat != dest){
				dest[12] = mat[12]; dest[13] = mat[13];
				dest[14] = mat[14]; dest[15] = mat[15];
			}
		} else {
			dest = mat;
		}
		dest[0] = g * s + k * t + o * u;
		dest[1] = h * s + l * t + p * u;
		dest[2] = i * s + m * t + q * u;
		dest[3] = j * s + n * t + r * u;
		dest[4] = g * v + k * w + o * x;
		dest[5] = h * v + l * w + p * x;
		dest[6] = i * v + m * w + q * x;
		dest[7] = j * v + n * w + r * x;
		dest[8] = g * y + k * z + o * A;
		dest[9] = h * y + l * z + p * A;
		dest[10] = i * y + m * z + q * A;
		dest[11] = j * y + n * z + r * A;
		return dest;
	};
	this.lookAt = function(eye, center, up, dest){
		var eyeX    = eye[0],    eyeY    = eye[1],    eyeZ    = eye[2],
			upX     = up[0],     upY     = up[1],     upZ     = up[2],
			centerX = center[0], centerY = center[1], centerZ = center[2];
		if(eyeX == centerX && eyeY == centerY && eyeZ == centerZ){return this.identity(dest);}
		var x0, x1, x2, y0, y1, y2, z0, z1, z2, l;
		z0 = eyeX - center[0]; z1 = eyeY - center[1]; z2 = eyeZ - center[2];
		l = 1 / Math.sqrt(z0 * z0 + z1 * z1 + z2 * z2);
		z0 *= l; z1 *= l; z2 *= l;
		x0 = upY * z2 - upZ * z1;
		x1 = upZ * z0 - upX * z2;
		x2 = upX * z1 - upY * z0;
		l = Math.sqrt(x0 * x0 + x1 * x1 + x2 * x2);
		if(!l){
			x0 = 0; x1 = 0; x2 = 0;
		} else {
			l = 1 / l;
			x0 *= l; x1 *= l; x2 *= l;
		}
		y0 = z1 * x2 - z2 * x1; y1 = z2 * x0 - z0 * x2; y2 = z0 * x1 - z1 * x0;
		l = Math.sqrt(y0 * y0 + y1 * y1 + y2 * y2);
		if(!l){
			y0 = 0; y1 = 0; y2 = 0;
		} else {
			l = 1 / l;
			y0 *= l; y1 *= l; y2 *= l;
		}
		dest[0] = x0; dest[1] = y0; dest[2]  = z0; dest[3]  = 0;
		dest[4] = x1; dest[5] = y1; dest[6]  = z1; dest[7]  = 0;
		dest[8] = x2; dest[9] = y2; dest[10] = z2; dest[11] = 0;
		dest[12] = -(x0 * eyeX + x1 * eyeY + x2 * eyeZ);
		dest[13] = -(y0 * eyeX + y1 * eyeY + y2 * eyeZ);
		dest[14] = -(z0 * eyeX + z1 * eyeY + z2 * eyeZ);
		dest[15] = 1;
		return dest;
	};
	this.perspective = function(fovy, aspect, near, far, dest){
		var t = near * Math.tan(fovy * Math.PI / 360);
		var r = t * aspect;
		var a = r * 2, b = t * 2, c = far - near;
		dest[0] = near * 2 / a;
		dest[1] = 0;
		dest[2] = 0;
		dest[3] = 0;
		dest[4] = 0;
		dest[5] = near * 2 / b;
		dest[6] = 0;
		dest[7] = 0;
		dest[8] = 0;
		dest[9] = 0;
		dest[10] = -(far + near) / c;
		dest[11] = -1;
		dest[12] = 0;
		dest[13] = 0;
		dest[14] = -(far * near * 2) / c;
		dest[15] = 0;
		return dest;
	};
	this.transpose = function(mat, dest){
		dest[0]  = mat[0];  dest[1]  = mat[4];
		dest[2]  = mat[8];  dest[3]  = mat[12];
		dest[4]  = mat[1];  dest[5]  = mat[5];
		dest[6]  = mat[9];  dest[7]  = mat[13];
		dest[8]  = mat[2];  dest[9]  = mat[6];
		dest[10] = mat[10]; dest[11] = mat[14];
		dest[12] = mat[3];  dest[13] = mat[7];
		dest[14] = mat[11]; dest[15] = mat[15];
		return dest;
	};
	this.inverse = function(mat, dest){
		var a = mat[0],  b = mat[1],  c = mat[2],  d = mat[3],
			e = mat[4],  f = mat[5],  g = mat[6],  h = mat[7],
			i = mat[8],  j = mat[9],  k = mat[10], l = mat[11],
			m = mat[12], n = mat[13], o = mat[14], p = mat[15],
			q = a * f - b * e, r = a * g - c * e,
			s = a * h - d * e, t = b * g - c * f,
			u = b * h - d * f, v = c * h - d * g,
			w = i * n - j * m, x = i * o - k * m,
			y = i * p - l * m, z = j * o - k * n,
			A = j * p - l * n, B = k * p - l * o,
			ivd = 1 / (q * B - r * A + s * z + t * y - u * x + v * w);
		dest[0]  = ( f * B - g * A + h * z) * ivd;
		dest[1]  = (-b * B + c * A - d * z) * ivd;
		dest[2]  = ( n * v - o * u + p * t) * ivd;
		dest[3]  = (-j * v + k * u - l * t) * ivd;
		dest[4]  = (-e * B + g * y - h * x) * ivd;
		dest[5]  = ( a * B - c * y + d * x) * ivd;
		dest[6]  = (-m * v + o * s - p * r) * ivd;
		dest[7]  = ( i * v - k * s + l * r) * ivd;
		dest[8]  = ( e * A - f * y + h * w) * ivd;
		dest[9]  = (-a * A + b * y - d * w) * ivd;
		dest[10] = ( m * u - n * s + p * q) * ivd;
		dest[11] = (-i * u + j * s - l * q) * ivd;
		dest[12] = (-e * z + f * x - g * w) * ivd;
		dest[13] = ( a * z - b * x + c * w) * ivd;
		dest[14] = (-m * t + n * r - o * q) * ivd;
		dest[15] = ( i * t - j * r + k * q) * ivd;
		return dest;
	};
}


