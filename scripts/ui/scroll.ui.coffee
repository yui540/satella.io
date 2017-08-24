class ScrollUI
	constructor: (params) ->
		@app = params.app

		@width     = params.width
		@max_width = params.max_width
		@aspect    = @width / @max_width
		@bar_width = @width * @aspect
		@per_width = @width - @bar_width

		@listeners = {}

	##
	# イベントリスナ追加
	# @param event:    イベント名
	# @param listener: コールバック関数 
	##
	on: (event, listener) ->
		if @listeners[event] is undefined
			@listeners[event] = []

		@listeners[event].push listener

	##
	# イベント発火
	# @param event: イベント名
	# @param data:  データ
	##
	emit: (event, data) ->
		if @listeners[event] is undefined
			return

		for listener in @listeners[event]
			listener data

	##
	# 描画
	##
	render: ->
		style = @createStyle()
		app   = @createElement style
		@app.innerHTML = app

		@scroll = @app.children[0]
		@bar    = @scroll.children[0]

		@bindEvent() # イベントの紐付け

	##
	# スタイルシートの生成
	##
	createStyle: ->
		style = "
			.scroll {
				position: relative;
				width: #{ @width }px; 
				height: 10px;
				background-color: #444; 
			}
			.bar {
				position: absolute;
				top: 0; left: 0;
				width: #{ @bar_width }px; 
				height: 10px;
				cursor: pointer;
				background-color: #111; 
			}
		".replace(/(\n|\s)/g, '')

		return style

	##
	# 要素の生成
	# @param style: スタイルシート
	##
	createElement: (style) ->
		app = "
			<div class=\"scroll\">
				<div class=\"bar\"></div>
			</div>
			<style>#{ style }</style>"

		return app

	##
	# イベントの紐付け
	##
	bindEvent: ->
		left = axis = null

		# mousedown -----------------------------
		@bar.addEventListener 'mousedown', (e) =>
			left = e.target.getBoundingClientRect().left
			rect = @scroll.getBoundingClientRect()

			left = e.clientX - left
			axis = e.clientX - rect.left

		# mousemove -----------------------------
		window.addEventListener 'mousemove', (e) =>
			if axis is null
				return

			rect = @scroll.getBoundingClientRect()
			x    = e.clientX - rect.left
			per  = x - left

			if per < 0
				per = 0
			else if per > @per_width
				per = @per_width

			@bar.style.left = per + 'px'
			@emit 'scroll', per / @per_width

		# mouseup -----------------------------
		window.addEventListener 'mouseup', (e) =>
			axis = null

module.exports = ScrollUI