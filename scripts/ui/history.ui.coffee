class HistoryUI
	constructor: (app) ->
		@app = app

	##
	# 描画
	##
	render: ->
		style = @createStyle()
		app   = @createElement style
		@app.innerHTML = app

		@back    = @app.children[0].children[0]
		@forward = @app.children[1].children[0]

		@bindEvent() # イベントの紐付け
		@check()     # 履歴のチェック

	##
	# スタイルシートの生成
	##
	createStyle: ->
		style = "
			.history {
				float: left;
			    width: 25px; height: 25px;
			    background-color: #444;
			    margin-left: 10px; cursor: pointer;
			}
			.history div {
				width: 100%; height: 100%;
			    background-position: center;
			    background-repeat: no-repeat;
			    background-size: auto 70%;
			    opacity: 0.4;
			}
			.history div[data-state=\"active\"] { opacity: 1; }

			.back {
				border-top-left-radius: 3px;
			    border-bottom-left-radius: 3px;
			}
			.back div { background-image: url(../img/history/back.png); }
			.forward { 
				border-top-right-radius: 3px;
			    border-bottom-right-radius: 3px;
				margin-left: 1px; 
			}
			.forward div { background-image: url(../img/history/foward.png); }
		".replace(/(\t|\n)/g, '')

		return style

	##
	# 要素の生成
	# @param style: スタイルシート
	##
	createElement: (style) ->
		app = "
			<div class=\"history back\"><div data-state=\"\"></div></div>
			<div class=\"history forward\"><div data-state=\"\"></div></div>
			<style>#{ style }</style>"

		return app

	##
	# イベントの紐付け
	##
	bindEvent: ->
		@eventBack()    # 戻るイベント
		@eventForward() # 進むイベント

	##
	# 戻るイベント
	##
	eventBack: ->
		# click -----------------------------------------------
		@back.addEventListener 'click', (e) =>
			history = app_state.current_history
			state   = e.target.getAttribute 'data-state'

			if state is 'active'
				history -= 1

				if history < 0 # 戻れるか
					history = 0

				json = app_state.history[history]
				global.app_json = copy json
				app_state.setState 'current_history', history

				@check()  # 履歴のチェック
				@reload() # リロード

		# mouseover -------------------------------------------
		@back.addEventListener 'mouseover', (e) =>
			UI.help.render({
				title:       'Back'
				description: '一つ前の履歴に戻ります。'
				x:           e.clientX
				y:           e.clientY
			})

		# mouseout --------------------------------------------
		@back.addEventListener 'mouseout', (e) =>
			UI.help.remove()

	##
	# 進むイベント
	##
	eventForward: ->
		@forward.addEventListener 'click', (e) =>
			history = app_state.current_history
			length  = app_state.history.length - 1
			state   = e.target.getAttribute 'data-state'

			if state is 'active'
				history += 1

				if length < history # これ以上進めるか
					history = length

				json     = app_state.history[history]
				global.app_json = copy json
				app_state.setState 'current_history', history

				@check()  # 履歴のチェック
				@reload() # リロード

		# mouseover -------------------------------------------
		@forward.addEventListener 'mouseover', (e) =>
			UI.help.render({
				title:       'Forward'
				description: '一つ前の履歴に進みます。'
				x:           e.clientX
				y:           e.clientY
			})

		# mouseout --------------------------------------------
		@forward.addEventListener 'mouseout', (e) =>
			UI.help.remove()

	##
	# 履歴の更新
	##
	pushHistory: ->
		length  = app_state.history.length - 1
		history = app_state.current_history
		diff    = length - history
		json    = copy app_json

		# 差分の消去
		if diff > 0
			for i in [0..diff]
				app_state.history.pop()

		# 100以内に丸める
		if app_state.history.length >= 100
			app_state.history.shift()
			app_state.current_history -= 1

		app_state.current_history += 1
		app_state.history.push json
		app_state.setState 'history', app_state.history

	##
	# チェック
	##
	check: ->
		history = app_state.current_history
		length  = app_state.history.length - 1

		if length > history
			@forward.setAttribute 'data-state', 'active'
		else
			@forward.setAttribute 'data-state', ''

		if history <= 0
			@back.setAttribute 'data-state', ''
		else
			@back.setAttribute 'data-state', 'active'

	##
	# 更新
	##
	reload: ->
		app_state.current_layer = 0
		UI.parameter_panel.reload() # パラメータパネル
		UI.layer_panel.reload()     # レイヤーパネル
		UI.project_panel.reload()   # プロジェクトパネル
		UI.view.render()            # 画面

module.exports = HistoryUI