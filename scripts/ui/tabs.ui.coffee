class TabsUI
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

		tabs         = @app.children[0]
		@project_tab = tabs.children[0]
		@layer_tab   = tabs.children[1]

		@bindEvent() # イベントの紐付け

	##
	# スタイルシートの生成
	##
	createStyle: ->
		style = "
			.tab {
				position: absolute;
				top: 10px; 
				width: 108px; height: 0;
			    border-bottom: 30px solid #393939;
			    border-left: 15px solid transparent;
			    border-right: 15px solid transparent;
				font-size: 12px;
			    color: #999; line-height: 30px;
			    text-align: center;
			    z-index: 0; cursor: pointer;
			}
			.tab:first-child { left: 0; }
			.tab:last-child { left: 121px; }
			#current-tab {
				color: #595DEF;
				border-bottom: 30px solid #292929;
				z-index: 1;
			}
		".replace(/(\t|\n)/g, '')

		return style

	##
	# 要素の生成
	##
	createElement: (style) ->
		app = "
			<div class=\"tabs\">
				<div id=\"current-tab\" class=\"project-tab tab\">project</div>
				<div id=\"\" class=\"layer-tab tab\">layer</div>
			</div>
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
	# イベントの紐付け
	##
	bindEvent: =>
		# project tab
		@project_tab.addEventListener 'click', =>
			@check 'project'
			@emit 'change', 'project'

		@layer_tab.addEventListener 'click', =>
			@check 'layer'
			@emit 'change', 'layer'

	##
	# 選択のチェック
	# @param name: タブ名
	##
	check: (name) ->
		@project_tab.id = ''
		@layer_tab.id   = ''

		if name is 'project'
			@project_tab.id = 'current-tab'
		else
			@layer_tab.id   = 'current-tab'

module.exports = TabsUI

