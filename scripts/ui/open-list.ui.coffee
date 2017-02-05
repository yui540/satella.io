class OpenListUI
	constructor: (app) ->
		@app = app

		@history   = []
		@listeners = {}

	##
	# 描画
	##
	render: -> 
		style = @createStyle()
		app   = @createElement style
		@app.innerHTML = app

		@open_list = @app.children[0]
		
	##
	# スタイルシートの生成
	##
	createStyle: ->
		style = "
			.open-list {}
			.open-list .history-li {
				width: 199px; height: 55px;
				border-bottom: solid 1px #595DEF;
				overflow: hidden; cursor: pointer;
			}
			.open-list .history-li[data-state=\"active\"] {
				background-color: #595DEF;
			}
			.open-list .history-li:before {
				display: block; clear: both; content: \"\";
			}
			.open-list .history-li .history-li-thumb {
				position: relative;
				float: left;
				width: 45px; height: 45px;
				border-radius: 50%;
				background-size: 100%;
				background-position: center;
				background-color: #4c4c4c;
				margin: 5px;
			}
			.open-list .history-li .history-li-author {
				position: absolute;
				bottom: 0; right: 0;
				background-color: #595DEF;
				width: 15px; height: 15px;
				line-height: 15px; text-align: center;
				font-size: 10px;
				border-radius: 50%; color: #fff;
				border: solid 1px #fff;
			}
			.open-list .history-li .history-li-info {
				float: right;
				width: 144px; height: 55px;
			}
			.open-list .history-li .history-li-name {
				font-size: 14px; font-weight: normal;
				line-height: 35px; color: #ccc;
				padding: 0 5px; box-sizing: border-box;
			}
			.open-list .history-li .history-li-dir {
				font-size: 8px; font-weight: normal;
				line-height: 15px; color: #ccc;
				padding: 0 5px; box-sizing: border-box;
			}
		".replace(/(\t|\n)/g, '')

		return style

	##
	# 要素の生成
	# @param style: stylesheet
	##
	createElement: (style) ->
		app = "
			<div class=\"open-list\"></div>
			<style>#{style}</style>"

		return app

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
	# クリア
	##
	clear: ->
		@open_list.innerHTML = ''

	##
	# 履歴の描画
	# @param list: 履歴のリスト
	##
	reload: (list) ->
		@clear() # クリア

		if list.length <= 0
			return

		for i in [0..list.length - 1]
			dir      = list[i]
			thumb    = "file://#{ dir }thumb.png"
			app_json = "#{ dir }app.json"

			app_json = JSON.parse @readFile app_json
 
			history = new History({ # 履歴リスト
				num:          i
				app:          @open_list
				directory:    dir
				thumb:        thumb
				author:       app_json.author
				content_name: app_json.content_name
				description:  app_json.description
				tag:          app_json.tag
			})
			history.render()
			@history.push history

		@bindEvent() # イベントの紐付け

	##
	# イベントの紐付け
	##
	bindEvent: ->
		history = @history
		length  = history.length

		# select ----------------------------------
		select_callback = (num) =>
			data = history[num]

			@check num # 選択の更新

			@emit 'select', { # イベント発火
				directory:    data.directory
				content_name: data.content_name
				author:       data.author
				tag:          data.tag
				description:  data.description
				thumb:        data.thumb
			}

		for i in [0..length - 1]
			history[i].on 'select', select_callback

	##
	# 選択の更新
	##
	check: (num) ->
		history = @history
		length  = history.length

		for i in [0..length - 1]
			if num is i
				history[i].active()
			else
				history[i].passive()

	##
	# ファイルの読み込み
	# @param f_path:   ファイルパス
	# @param encoding: エンコーディング
	##
	readFile: (f_path, encoding='utf8') ->
		fs = require 'fs'

		try
			return fs.readFileSync f_path, encoding
		catch e
			return false
		
class History
	constructor: (params) ->
		@num = params.num

		@history = null
		@app     = params.app

		@directory    = params.directory
		@description  = params.description
		@thumb        = params.thumb
		@author       = params.author
		@content_name = params.content_name
		@tag          = params.tag

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
		if @listeners[event] is undefined
			return;

		for callback in @listeners[event]
			callback data

	##
	# 描画
	##
	render: ->
		app = document.createElement 'section'
		app.className = 'history-li'

		thumb = document.createElement 'div'
		thumb.className             = 'history-li-thumb'
		thumb.style.backgroundImage = "url(#{ @thumb })"
		thumb.innerHTML = "
			<p class=\"history-li-author\">
				#{ @author[0].toUpperCase() }
			</@>"

		info = document.createElement 'div'
		info.className = 'history-li-info'
		info.innerHTML = "
			<h2 class=\"history-li-name\">
				#{ @content_name }
			</h2>
			<h3 class=\"history-li-dir\">
				#{ @directory }
			</h3>"

		app.appendChild thumb
		app.appendChild info
		@app.appendChild app
		@history = app

		# click -----------------------------
		app.onclick = =>
			@emit 'select', @num

	##
	# 選択
	##
	active: ->
		@history.setAttribute 'data-state', 'active'

	##
	# 非選択
	##
	passive: ->
		@history.setAttribute 'data-state', ''

module.exports = OpenListUI