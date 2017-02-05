'use strict';

// module
var fs            = require('fs')
,   electron      = require('electron')
,   app           = electron.app
,   BrowserWindow = electron.BrowserWindow
,   ipcMain       = electron.ipcMain
,   dialog        = electron.dialog;

// data
var STATE = {}  // プロジェクト情報
,   DATA  = {}  // ウィンドウのデータ
,   VIEW  = {}; // ウィンドウ

/******************************************************************
 *
 * app
 * 
 ******************************************************************/
app.on('ready', () => { // プロセス準備完了
	set_data();

	create_window('INIT');
});

/******************************************************************
 *
 * ipc
 * 
 ******************************************************************/

/**
 * 指定のウィンドウを閉じる
 */
ipcMain.on('close_window', (event, id) => {
	VIEW[id].close();
});

/**
 * 指定のウィンドウを最小化
 */
ipcMain.on('quit_window', (event, id) => {
	VIEW[id].minimize();
});

/**
 * プロジェクト履歴の取得
 */
ipcMain.on('history', (event) => {
	let save = readFile(__dirname + '/lib/save.json');
	save     = JSON.parse(save);
	save     = kill_history(save);
	writeFile(__dirname + '/lib/save.json', JSON.stringify(save));

	event.sender.send('history', save);
});

/**
 * 新規プロジェクト
 */
ipcMain.on('new_project', (event, params) => {
	dialog.showSaveDialog(VIEW['INIT'], {
			properties: ['createDirectory']
		}, function(d_path) {
			if(!d_path) return;

			STATE.directory_path = d_path + '/';

			create_project({ // プロジェクトアーカイブの作成
				directory:    d_path + '/', 
				author:       params.author, 
				content_name: params.content_name, 
				description:  params.description, 
				tag:          params.tag
			});

			// メインアプリケーション起動
			create_window('MAIN');

			// プロジェクトの履歴更新
			push_history(STATE.directory_path);

			setTimeout(function() {VIEW['INIT'].close()}, 1000);
		});
});

/** 
 * プロジェクトを開く
 */
ipcMain.on('open_project', (event, directory) => {
	STATE.directory_path = directory;

	// app.jsonの存在確認
	if(!existFile(directory + 'app.json')) {
		return;
	}

	// メインアプリケーション起動
	create_window('MAIN');

	// プロジェクトの履歴更新
	push_history(STATE.directory_path);

	setTimeout(function() {VIEW['INIT'].close()}, 1000);
});

/**
 * 他のプロジェクトを開く
 */
ipcMain.on('other_project', (event, params) => {
	dialog.showOpenDialog(VIEW['INIT'], {
			title: 'Open project',
			properties: ['openDirectory']
		}, function(d_path) {
			if(!d_path) return;

			STATE.directory_path = d_path + '/';

			// app.jsonの存在確認
			if(!existFile(d_path + '/app.json')) {
				return;
			}

			// メインアプリケーション起動
			create_window('MAIN');

			// プロジェクトの履歴更新
			push_history(STATE.directory_path);

			setTimeout(function() {VIEW['INIT'].close()}, 1000);
		});
});

/**
 * プロジェクトの起動
 */
ipcMain.on('start_project', (event, params) => {
	event.sender.send('start_project', STATE);
});

/**
 * SDKの生成
 */
ipcMain.on('sdk', (event, params) => {
	dialog.showOpenDialog(VIEW['MAIN'], {
			title: 'create SDK',
			properties: ['openDirectory']
		}, function(d_path) {
			if(!d_path) return;

			create_sdk(d_path);
			event.sender.send('sdk');
		});
});

/******************************************************************
 *
 * function
 * 
 ******************************************************************/

/**
 * プロジェクトの履歴更新
 */
function push_history(dir) {
	let save = JSON.parse(readFile(__dirname + '/lib/save.json'));

	save = kill_history(save); // パスが切れているものを消去

	for(let i=0; i < save.length; i++) { // 重複のチェック
		let _dir = save[i];
		if(dir === _dir) 
			save.splice(i, 1);
	}

	save.push(dir);  
	if(save.length > 20) // 20以内で丸める
		save.shift();

	save = JSON.stringify(save);
	writeFile(__dirname + '/lib/save.json', save);
}

/**
 * プロジェクト履歴のパスが切れているものを消去
 */
function kill_history(save) {
	let _save = copy(save);
	for(let i=0; i < save.length; i++) {
		let dir = save[i];
		if(!existFile(dir + 'app.json'))
			_save.splice(i, 1);
	}

	return _save;
}

/**
 * ウィンドウ情報の設定
 */
function set_data() {
	let size = electron.screen.getPrimaryDisplay().workAreaSize;
	DATA['INIT'] = { // init
		FILE_NAME:  'init.html',
		WIDTH:      600, 
		HEIGHT:     400,
		MIN_WIDTH:  600, 
		MIN_HEIGHT: 400,
		RESIZE:     false
	};
	DATA['MAIN'] = { // main
		FILE_NAME:  'main.html',
		WIDTH:      size.width, 
		HEIGHT:     size.height,
		MIN_WIDTH:  1000, 
		MIN_HEIGHT: 650,
		RESIZE:     true
	};
}

/**
 * 新規ウィンドウの作成
 */
function create_window(id) {
	VIEW[id] = new BrowserWindow({
		width:       DATA[id].WIDTH,
		height:      DATA[id].HEIGHT,
		minWidth:    DATA[id].MIN_WIDTH,
		minHeight:   DATA[id].MIN_HEIGHT,
		resizable:   DATA[id].RESIZE,
		transparent: true,
		frame:       false,
		show:        false
	});
	VIEW[id].loadURL(`file://${__dirname}/views/${DATA[id].FILE_NAME}`);
	VIEW[id].on('ready-to-show', () => {
		VIEW[id].show();
	});
	VIEW[id].on('closed', () => {
		VIEW[id] = null; 
	});
}

/**
 * プロジェクトアーカイブの作成
 */
function create_project(params) {
	let thumb = readFile( // thumb.png
		__dirname + '/img/assets/thumb.png', 'base64');

	let app_state_json = JSON.stringify({ // app-state.json
		directory: params.directory, // ディレクトリパス
		current_time: 0,             // 現在時間
		current_layer: 0,            // 選択レイヤー
		current_parameter: 'default',// 選択パラメータ
		current_keyframes: false,    // 選択キーフレーム
		current_history: 0,          // 履歴位置
		play: false,                 // 再生有無
		mode: 'polygon',             // マウスモード
		scale: 1,                    // 拡大縮小比
		position: {                  // 位置
			x: 0.5,
			y: 0.5
		},
		parameter: {                 // パラメータの状態
			default: {
				x: 0.5, y: 0.5
			}
		},
		history: []                  // 履歴
	});

	let app_json = JSON.stringify({    // app.json
		author: params.author,                 // 作成者
		content_name: params.content_name,     // 作品名
		description: params.description,       // 説明文
		tag: params.tag,                       // タグ
		layer: [],                             // レイヤー
		parameter: {                           // パラメータ
			default: {
				type: 4, 
				layer: []
			}
		},
		keyframes: {                           // キーフレーム
			default: {
				default: []	
			}
		}
	});

	mkdir(params.directory);
	mkdir(params.directory + '/texture');
	writeFile( // thumb.png
		params.directory + '/thumb.png', 
		thumb, 'base64');
	writeFile( // app_state.json
		params.directory + '/app-state.json', 
		app_state_json);
	writeFile( // eriri.json
		params.directory + '/app.json', 
		app_json);
}

/**
 * SDKの作成
 */
function create_sdk(directory) {
	// パス
	let axis_path = STATE.directory_path
	,   sdk_js    = __dirname + '/lib/sdk.js'
	,   app_json  = axis_path + 'app.json'
	,   texture   = axis_path + 'texture'
	,   thumb     = axis_path + 'thumb.png';

	// データ
	let sdk_js_data   = readFile(sdk_js)
	,   app_json_data = readFile(app_json)
	,   thumb_data    = readFile(thumb, 'base64')
	,   texture_data  = {}
	,   texs          = readdir(texture);
	for(let i=0; i < texs.length; i++) {
		if(texs[i].match(/.+\.png/)) {
			let data = readFile(texture + '/' + texs[i], 'base64');
			texture_data[texs[i]] = data;
		}
	}

	// 書き出し
	mkdir(directory + '/satella-sdk');
	mkdir(directory + '/satella-sdk/texture');
	mkdir(directory + '/satella-sdk/lib');
	writeFile(directory + '/satella-sdk/sdk.js', sdk_js_data);
	writeFile(directory + '/satella-sdk/lib/app.json', app_json_data);
	writeFile(directory + '/satella-sdk/thumb.png', thumb_data, 'base64');
	for(let name in texture_data) {
		let file_name = directory + '/satella-sdk/texture/' + name
		,   data      = texture_data[name];

		writeFile(file_name, data, 'base64');
	}
}

/**
 * ディレクトリの読み込み
 */
function readdir(directory) {
	try {
		return fs.readdirSync(directory);
	} catch(err) {
		return false;
	}
}

/**
 * ファイルの存在確認
 */
function existFile(file_name) {
	try {
		fs.statSync(file_name);
		return true;
	} catch(err) {
		return false;
	}
}

/**
 * ファイルの作成
 */
function writeFile(file_name, data, encoding='utf8') {
	try {
		fs.writeFileSync(file_name, data, encoding);
		return true;
	} catch(err) {
		return false;
	}
}

/**
 * ファイルの読み込み
 */
function readFile(file_name, encoding='utf8') {
	try {
		return fs.readFileSync(file_name, encoding);
	} catch(err) {
		return false;
	}
}

/**
 * コピー
 */
function copy(obj) {
	return JSON.parse(JSON.stringify(obj));
}

/**
 * ディレクトリの作成
 */
function mkdir(directory_name) {
	try {
		fs.mkdirSync(directory_name);
		return true;
	} catch(err) {
		return false;
	}
}