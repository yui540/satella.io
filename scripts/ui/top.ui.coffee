class TopUI
	constructor: (app) ->
		@app = app

		@listeners = {}

	##
	# 描画
	##
	render: -> 
		style = @createStyle()
		app   = @createElement style
		@app.innerHTML = app

		@top = @app.children[0]

		@renderStart() # スタート画面
		
	##
	# スタイルシートの生成
	##
	createStyle: ->
		style = "
			
		".replace(/(\t|\n)/g, '')

		return style

	##
	# 要素の生成
	# @param style: stylesheet
	##
	createElement: (style) ->
		app = "
			<div class=\"top\"></div>
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
	# スタート画面
	##
	renderStart: ->
		style = "
			.start-view {
				width: 400px; height: 365px;
				background-image: url(../img/assets/start.png);
				background-size: 60%;
				background-repeat: no-repeat;
				background-position: center;
			}
		".replace(/(\t|\n)/g, '')

		app = "
			<div class=\"start-view\"></div>
			<style>#{style}</style>"

		@top.innerHTML = app

	##
	# スタート画面
	##
	renderNew: ->
		style = "
			.new-view .logo {
				width: 70px; height: 70px;
				background-image: url(../img/assets/logo.png);
				background-position: center;
				background-size: 100%;
				margin: 20px auto;
			}
			.new-view input[type=\"text\"] {
				width: 300px; height: 30px;
				display: block; color: #ccc;
				margin: 20px auto;
				background-color: #383c51;
				font-size: 10px; line-height: 30px;
				box-sizing: border-box; padding: 0 10px;
			}
			.new-view input[type=\"text\"]:focus {
				outline: none;
			}
			.new-view .create-btn {
				width: 150px; height: 30px;
				background-color: #595DEF;
				font-size: 14px; color: #ccc;
				text-align: center; line-height: 30px;
				margin: 0 auto; cursor: pointer;
				border-radius: 3px;
			}
		".replace(/(\t|\n)/g, '')

		app = "
			<div class=\"new-view\">
				<div class=\"logo\"></div>
				<input type=\"text\" id=\"author\" maxlength=\"10\" placeholder=\"author ( 10char )\" />
				<input type=\"text\" id=\"content-name\" maxlength=\"10\" placeholder=\"content_name ( 10char )\" />
				<input type=\"text\" id=\"description\" maxlength=\"50\" placeholder=\"description ( 50char )\" />
				<input type=\"text\" id=\"tag\" maxlength=\"10\" placeholder=\"tag ( 10char )\" />
				<div class=\"create-btn\">create</div>
			</div>
			<style>#{style}</style>"

		@top.innerHTML = app

		author       = @top.children[0].children[1]
		content_name = @top.children[0].children[2]
		description  = @top.children[0].children[3]
		tag          = @top.children[0].children[4]
		btn          = @top.children[0].children[5]

		# 新規のイベント
		@eventNew(author, content_name, description, tag, btn)

	##
	# 新規のイベント
	# @param author
	# @param cotent_name
	# @param description
	# @param tag
	# @param btn 
	##
	eventNew: (author, content_name, description, tag, btn) ->
		ipcRenderer = require('electron').ipcRenderer

		btn.addEventListener 'click', =>
			data              = {} 
			data.author       = author.value.substring(0, 10).replace(/(<|>\"\')/g, '')
			data.content_name = content_name.value.substring(0, 10).replace(/(<|>\"\')/g, '')
			data.description  = description.value.substring(0, 50).replace(/(<|>\"\')/g, '')
			data.tag          = tag.value.substring(0, 10).replace(/(<|>\"\')/g, '')

			for key, val of data
				if val.length < 1
					alert '入力されていない箇所があります。'
					return

			if not data.author.match(/[a-z0-9A-Z]/g)
				alert 'authorは、英数字で入力してください。'
				return

			ipcRenderer.send 'new_project', data

	##
	# プロジェクト画面
	##
	renderProject: (params) ->
		style = "
			.project-view {
				position: relative;
				width: 400px; height: 365px;
				display: table;
			}
			.top-text {
				position: absolute;
				top: 280px; left: 170px;
				width: 60px; height: 40px;
				font-size: 12px; color: #fff;
				text-align: center; line-height: 40px;
			}
			.top-open,
			.top-preview {
				position: absolute;
				top: 162.5px;
				width: 40px; height: 40px;
				border-radius: 50%;
				background-size: 100%;
				background-position: center;
			}
			.top-open[data-state=\"active\"],
			.top-preview[data-state=\"active\"] {
				transition: all 0.5s ease 0s;
				background-color: #fff;
			}
			.top-open { 
				left: 60px; 
				background-image: url(../img/assets/top-open.png);
			}
			.top-preview { 
				left: 300px; 
				background-image: url(../img/assets/top-preview.png);
			}
			.project-view .inner {
				display: table-cell;
				vertical-align: middle;
			}
			.project-view .inner .thumb {
				position: relative;
				background-color: #383c51;
				border: solid 0px #383c51;
				border-radius: 50%;
				width: 200px; height: 200px;
				margin: 0 auto; overflow: hidden;
				transition: all 0.3s ease 0s;
			}
			.project-view .inner .thumb:active {
				transform: scale(0.8);
			}
			.project-view .inner .thumb[data-mode=\"open\"],
			.project-view .inner .thumb[data-mode=\"preview\"] {
				transition: all 0.5s ease 0s;
				background-color: #595DEF;
				border-color: #595DEF;
			}
			.project-view .inner .thumb:hover {
				border-width: 40px;
			}
			.project-view .inner .thumb img {
				position: absolute; 
				top: 0; left: 0;
				width: 200px; height: 200px;
			}
		".replace(/(\t|\n)/g, '')

		app = "
			<div class=\"project-view\">
				<div class=\"inner\">
					<div class=\"thumb\">
						<img src=\"#{ params.thumb }\" />
					</div>
				</div>
			</div>
			<div class=\"top-open\"></div>
			<div class=\"top-preview\"></div>
			<div class=\"top-text\"></div>
			<style>#{style}</style>"

		@top.innerHTML = app

		# プロジェクトを開くイベント
		
		btn         = @top.children[0].children[0].children[0]
		open_btn    = @top.children[1]
		preview_btn = @top.children[2]
		text        = @top.children[3]
		@eventProject btn, open_btn, preview_btn, text, params.directory

	##
	# プロジェクトを開くイベント
	# @param open_btn:  ボタン
	# @param directory: ディレクトリパス
	##
	eventProject: (btn, open_btn, preview_btn, text, directory) ->
		ipcRenderer = require('electron').ipcRenderer

		# mousemove --------------------------
		btn.addEventListener 'mousemove', (e) =>
			rect   = btn.getBoundingClientRect()
			x      = e.clientX - rect.left
			y      = e.clientY - rect.top
			width  = rect.width
			height = rect.height
			p_x    = x / width
			p_y    = y / height

			if p_x > 0.5
				open_btn.setAttribute 'data-state', ''
				preview_btn.setAttribute 'data-state', 'active'
				btn.setAttribute 'data-mode', 'preview'
				text.innerHTML = 'preview'
			else
				open_btn.setAttribute 'data-state', 'active'
				preview_btn.setAttribute 'data-state', ''
				btn.setAttribute 'data-mode', 'open'
				text.innerHTML = 'open'

		# mousemove --------------------------
		btn.addEventListener 'mouseout', (e) =>
			btn.setAttribute         'data-mode',  ''
			open_btn.setAttribute    'data-state', ''
			preview_btn.setAttribute 'data-state', ''
			text.innerHTML = ''
			btn.children[0].style.top  = 0
			btn.children[0].style.left = 0

		# click ------------------------------
		btn.addEventListener 'click', ->
			mode = btn.getAttribute 'data-mode'

			if mode is 'open'
				ipcRenderer.send 'open_project', directory
			else
				#
				# プレビュー
				#

module.exports = TopUI