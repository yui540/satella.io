ID = 'MAIN'

global.timer     = null # タイマー
global.app_state = {}   # アプリケーション状態
global.app_json  = {}   # app.json
global.UI        = {}   # UI
global.SIZE      = {}   # UIサイズ

# module
global.fs          = require 'fs'
global.ipcRenderer = require('electron').ipcRenderer
global.Component   = require '../scripts/component.coffee'

# プロジェクトの起動
ipcRenderer.send 'start_project'
ipcRenderer.on 'start_project', (event, state) ->
	path1 = state.directory_path + 'app.json'
	path2 = state.directory_path + 'app-state.json'

	global.app_json  = JSON.parse readFile path1
	global.app_state = JSON.parse readFile path2

	global.app_state = new Component.AppState({
		directory:         state.directory_path
		current_time:      app_state.current_time
		current_layer:     app_state.current_layer
		current_parameter: app_state.current_parameter
		current_keyframes: app_state.current_keyframes
		play:              app_state.play
		mode:              app_state.mode
		scale:             app_state.scale
		position:          app_state.position
		parameter:         app_state.parameter
		history:           app_state.history
		current_history:   app_state.current_history
	})

	app_start() # 起動

##
# アプリケーションの起動
##
global.app_start = ->
	layout() # レイアウトの構築

	############################################################
	# UIコーポネント
	############################################################
	global.UI.layer_panel = new Component.LayerPanel({
		app:    document.getElementById 'layer-panel'
		width:  SIZE['DATA-PANEL'].WIDTH - 1
		height: SIZE['DATA-PANEL'].HEIGHT
	})
	UI.layer_panel.render()

	global.UI.project_panel = new Component.ProjectPanel({
		app:    document.getElementById 'project-panel'
		width:  SIZE['DATA-PANEL'].WIDTH - 1
		height: SIZE['DATA-PANEL'].HEIGHT
	})
	UI.project_panel.render()

	global.UI.controls = new Component.Controls(
		document.getElementById 'controls-panel')
	UI.controls.render()

	global.UI.view = new Component.View({
		app:    document.getElementById 'display'
		width:  SIZE['DISPLAY'].WIDTH
		height: SIZE['DISPLAY'].HEIGHT
	});

	global.UI.status = new Component.Status(
		document.getElementById 'status')
	UI.status.render()

	global.UI.help = new Component.Help(
		document.getElementById 'help')

	global.UI.image_view = new Component.ImageView(
		document.getElementById 'add-image-view')

	global.UI.save_texture = new Component.SaveTexture(
		document.getElementById 'save-canvas')

	global.UI.timeline = new Component.Timeline(
		document.getElementById 'timeline-bar')
	UI.timeline.render(20)

	global.UI.scroll = new Component.Scroll({
		app:       document.getElementById 'timeline-scroll-bar'
		width:     SIZE['TIMELINE'].WIDTH
		max_width: UI.timeline.width
	})
	UI.scroll.render()

	global.UI.put_keyframe = new Component.PutKeyframe(
		document.getElementById 'put-keyframe')
	UI.put_keyframe.render()

	global.UI.mode_controls = new Component.ModeControls(
		document.getElementById 'mode-controls')
	UI.mode_controls.render()

	global.UI.mode_navigator = new Component.ModeNavigator(
		document.getElementById 'mode-navigator')
	UI.mode_navigator.render()

	global.UI.history = new Component.History(
		document.getElementById 'history')
	UI.history.render()

	global.UI.tabs = new Component.Tabs(
		document.getElementById 'tabs')
	UI.tabs.render()

	global.UI.context_menu = new Component.ContextMenu(
		document.getElementById 'context-menu')

	global.UI.notification = new Component.Notification(
		document.getElementById 'notification')
	UI.notification.render()

	global.UI.add_parameter = new Component.AddParameter(
		document.getElementById 'add-parameter-view')

	global.UI.parameter_info = new Component.ParameterInfo({
		app:    document.getElementById 'parameter-info'
		width:  SIZE['PARAMETER-INFO'].WIDTH,
		height: SIZE['PARAMETER-INFO'].HEIGHT
	})
	UI.parameter_info.render()

	global.UI.parameter_panel = new Component.ParameterPanel({
		app:    document.getElementById 'parameter-panel'
		width:  SIZE['PARAMETER-PANEL'].WIDTH,
		height: SIZE['PARAMETER-PANEL'].HEIGHT
	})
	UI.parameter_panel.render()

	global.UI.animation_panel = new Component.AnimationPanel(
		document.getElementById 'animation-panel')
	UI.animation_panel.render()

	global.UI.sidebar = new Component.SideBar(
		document.getElementById 'side-bar')
	UI.sidebar.render()

	global.UI.thumb = new Component.Thumb({
		app:  document.getElementById 'thumb-canvas'
		size: 400
	})
	UI.thumb.render()

	global.UI.tool = new Component.Tool(
		document.getElementById 'tool')
	UI.tool.render()

	global.UI.save = new Component.Save()

	############################################################
	# イベント処理
	############################################################

	##
	# 閉じる
	##
	document.getElementById('close-btn').onclick = ->
		ipcRenderer.send 'close_window', ID

	##
	# 最小化
	##
	document.getElementById('quit-btn').onclick = ->
		ipcRenderer.send 'quit_window', ID

	##
	# レイヤーの追加
	##
	UI.tool.on 'add', (params) ->
		rand   = Math.floor Math.random() * 100000
		f_name = "texture/texture#{ rand }.png"
		f_path = app_state.directory + f_name
		data   = params.data.replace(/^data:image\/png;base64,/, '')

		writeFile f_path, data, 'base64' # 画像書き込み

		UI.view.addLayer { # View
			name:    params.name
			mesh:    params.mesh
			pos:     params.pos
			size:    params.size
			quality: params.quality
			url:     f_name
		}

		UI.layer_panel.addCell { # LayerPanel
			active: 'show'
			name:   params.name
			img:    "file://#{ f_path }"
		}

		UI.project_panel.reload()           # プロジェクト情報の更新
		UI.notification.emit 'レイヤーの追加' # 追加

	##
	# スクロール
	##
	UI.scroll.on 'scroll', (per) ->
		diff = SIZE['TIMELINE'].WIDTH - UI.timeline.width
		UI.timeline.move diff * per

	##
	# タブ切り替え
	##
	UI.tabs.on 'change', (param) ->
		if(param is 'project')
			UI.project_panel.open()
		else
			UI.project_panel.close()

	##
	# キーフレームポイントの設置
	##
	UI.put_keyframe.on 'put', ->
		UI.history.pushHistory()
		UI.timeline.reload()

	##
	# マウスのモード変更時
	##
	app_state.bind 'mode', ->
		UI.status.setMode app_state.mode
		UI.view.render()

	##
	# 拡大縮小
	##
	app_state.bind 'scale', ->
		UI.status.setScale app_state.scale
		UI.view.render()

	##
	# 位置
	##
	app_state.bind 'position', ->
		UI.status.setPos app_state.position.x, app_state.position.y
		UI.view.render()

	##
	# レイヤーの選択時
	##
	app_state.bind 'current_layer', ->
		parameter = app_state.current_parameter
		type      = app_json.parameter[parameter].type
		length    = app_json.layer.length
		layers    = new Array length

		if length <= 0
			return

		for i in [0..length - 1]
			for n in [0..app_json.layer.length - 1]
				num   = UI.layer_panel.cells[i].num
				name1 = UI.layer_panel.cells[i].name
				name2 = app_json.layer[n].name

				if name1 is name2
					layers[num] = copy app_json.layer[n]

		app_json.layer = copy layers

		UI.view.render()
		UI.layer_panel.selectCell()
		UI.parameter_info.active {
			name: parameter
			type: type
		}
		UI.project_panel.reload()

	##
	# 再生時間の変更時
	##
	app_state.bind 'current_time', ->
		time      = app_state.current_time
		keyframes = app_state.current_keyframes

		if keyframes isnt false
			for name, points of app_json.keyframes[keyframes]
				type = app_json.parameter[name].type
				m    = getMiddleVal points

				UI.parameter_panel.slider[name].move m.x, m.y

		UI.timeline.movePic time
		UI.animation_panel.setTime time
		UI.view.render()

	##
	# 選択パラメータ
	##
	app_state.bind 'current_parameter', ->
		keyframes = app_state.current_keyframes
		parameter = app_state.current_parameter
		type      = app_json.parameter[parameter].type

		if keyframes isnt false
			if app_json.keyframes[keyframes][parameter] is undefined
				app_json.keyframes[keyframes][parameter] = []

		UI.parameter_panel.active parameter
		UI.parameter_info.active {
			name: parameter
			type: type
		}
		UI.timeline.reload()

	##
	# 選択キーフレーム
	##
	app_state.bind 'current_keyframes', ->
		keyframes = app_state.current_keyframes
		parameter = app_state.current_parameter

		if keyframes isnt false
			if app_json.keyframes[keyframes][parameter] is undefined
				app_json.keyframes[keyframes][parameter] = []

		UI.animation_panel.setAnimation keyframes
		UI.parameter_panel.reload()
		UI.timeline.reload()

	##
	# パラメータ
	##
	app_state.bind 'parameter', ->
		UI.view.render()

	##
	# 履歴
	##
	app_state.bind 'history', ->
		UI.history.check()

	##
	# 履歴位置
	##
	app_state.bind 'current_history', ->


	##
	# 再生・停止の変更時
	##
	app_state.bind 'play', ->

	init() # 初期履歴を更新
	load() # プロジェクトデータの展開

##
# レイアウトの構築
##
global.layout = ->
	width  = window.innerWidth
	height = window.innerHeight

	SIZE['APPLICATION'] = {
		WIDTH:  width
		HEIGHT: height
	}
	SIZE['TITLE-BAR'] = {
		WIDTH:  width
		HEIGHT: 20
	}
	SIZE['TOOL'] = {
		WIDTH:  width - 260
		HEIGHT: 40
	}
	SIZE['WORK-SPACE'] = {
		WIDTH:  260,
		HEIGHT: height - 90
	}
	SIZE['PARAMETER'] = {
		WIDTH:  250
		HEIGHT: height - 130
	}
	SIZE['PARAMETER-INFO'] = {
		WIDTH:  SIZE['PARAMETER'].WIDTH - 1
		HEIGHT: SIZE['PARAMETER'].HEIGHT / 2
	}
	SIZE['PARAMETER-PANEL'] = {
		WIDTH:  SIZE['PARAMETER'].WIDTH - 1
		HEIGHT: SIZE['PARAMETER'].HEIGHT / 2
	}
	SIZE['VIEW'] = {
		WIDTH:  width - 560
		HEIGHT: height - 130
	}
	SIZE['SIDE-BAR'] = {
		WIDTH:  50
		HEIGHT: height - 130
	}
	SIZE['ANIMATION-PANEL'] = {
		WIDTH:  260
		HEIGHT: 70
	}
	SIZE['TIMELINE'] = {
		WIDTH:  width - 260
		HEIGHT: 70
	}
	SIZE['TABS'] = {
		WIDTH:  260
		HEIGHT: 40
	}
	SIZE['DATA-PANEL'] = {
		WIDTH:  260
		HEIGHT: (SIZE['WORK-SPACE'].HEIGHT - 40) / 2 + 5
	}
	SIZE['CONTROLS-PANEL'] = {
		WIDTH:  260
		HEIGHT: (SIZE['WORK-SPACE'].HEIGHT - 40) / 2 - 5
	}
	SIZE['DISPLAY'] = {
		WIDTH:  SIZE['VIEW'].WIDTH - 20
		HEIGHT: SIZE['VIEW'].HEIGHT - 75
	}
	SIZE['CONTROLS'] = {
		WIDTH:  SIZE['VIEW'].WIDTH
		HEIGHT: 30
	}

	app_style = document.getElementById 'app-style'
	app_style.innerHTML = ''
	for key, size of SIZE
		app_style.innerHTML +=
			'#' + key.toLowerCase() + "{
				width: #{ size.WIDTH }px;
				height: #{ size.HEIGHT }px;
			}".replace(/\s/g, '')

##
# 初期履歴の更新
##
global.init = ->
	if app_state.history.length > 0
		return

	json = copy app_json
	app_state.history.push json

##
# プロジェクトデータの展開
##
global.load = ->
	UI.view.initLoadResource(() ->
		UI.view.render()
	)
	UI.layer_panel.reload()     # レイヤーパネル
	UI.project_panel.reload()   # プロジェクト情報
	UI.sidebar.reload()         # サイドバー
	UI.timeline.reload()        # タイムライン
	UI.parameter_panel.reload() # パラメータパネル

##
# オブジェクトのコピー
##
global.copy = (obj) ->
	return JSON.parse JSON.stringify obj

##
# キーフレームの中間値を取得
##
global.getMiddleVal = (points, type) ->
	time   = app_state.current_time
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
			d_x    = yuki540.diff(x2, x1) * per
			x      = x1 + d_x
			d_y    = 0
			y      = 0
			middle = {}

			middle.x = x

			if y1 isnt undefined
				d_y      = yuki540.diff(y2, y1) * per
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
# ファイルの書き込み
# @param file_name: ファイルパス
# @param data:      ファイル内容
# @param encoding:  エンコーディング
##
global.writeFile = (file_path, data, encoding='utf8') ->
	try
		fs.writeFileSync file_path, data, encoding
		return true;
	catch err
		return false

##
# ファイルの読み込み
# @param file_path: ファイルパス
# @param encoding:  エンコーディング
##
global.readFile = (file_path, encoding) ->
	try
		return fs.readFileSync file_path, encoding
	catch err
		return false
