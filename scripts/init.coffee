ID = 'INIT'

UI       = {} # UIコーポネント
app_json = {} # app.json

# module
ipcRenderer = require('electron').ipcRenderer
Component   = require '../scripts/component.coffee'

# load ---------------------------------------------
window.addEventListener 'load', ->
	##
	# UI
	##
	UI.open_list = new Component.OpenList(
		document.getElementById 'open-list')
	UI.open_list.render()

	UI.top = new Component.Top(
		document.getElementById 'top')
	UI.top.render()

	##
	# 閉じる
	##
	document.getElementById('close').onclick = ->
		ipcRenderer.send 'close_window', ID

	##
	# 最小化
	##
	document.getElementById('quit').onclick = ->
		ipcRenderer.send 'quit_window', ID

	##
	# 他のプロジェクトを開く
	##
	document.getElementById('open').onclick = ->
		ipcRenderer.send 'other_project'

	##
	# プロジェクトの作成
	##
	document.getElementById('new').onclick = ->
		UI.top.renderNew()

	##
	# トップ画面
	##
	document.getElementById('news').onclick = ->
		UI.top.renderStart()
		UI.open_list.check()

	##
	# プロジェクト履歴の取得
	##
	ipcRenderer.send 'history'
	ipcRenderer.on 'history', (event, list) ->
		UI.open_list.reload list

	##
	# プロジェクトの選択
	##
	UI.open_list.on 'select', (data) ->
		UI.top.renderProject data

