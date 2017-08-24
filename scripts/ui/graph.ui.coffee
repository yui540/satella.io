class GraphUI
	constructor: (params) ->
		@app   = params.app
		@graph = null
		@ball  = null

		@width     = params.width
		@height    = params.height
		@color     = '#595DEF'
		@current   = {}
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
		listener = @listeners[event]

		if listener is undefined
			return;

		for callback in listener
			callback data

	##
	# 描画
	##
	render: ->
		style = @createStyle()
		app   = @createElement style
		@app.innerHTML = app

		@graph = @app.children[0]
		@ball  = @graph.children[0]

		@bindEvent() # イベントの紐付け

	##
	# スタイルシートの生成
	##
	createStyle: ->
		selector = ''
		if @app.classList[0] isnt undefined
			selector = '.' + @app.classList[0] + ' '
		else if @app.id isnt undefined
			selector = '#' + @app.id + ' '

		style = "
			#{ selector }.graph {
				position: relative;
				width: #{ @width }px;
				height: #{ @height }px;
				background-color: #444;
			}
			#{ selector }.graph:before,
			#{ selector }.graph:after {
				position: absolute;
				content: \"\"; display: block;
				background-color: #{ @color };
			}
			#{ selector }.graph:before {
				top: #{ @height / 2 - 0.5 }px; left: 0;
				width: 100%; height: 1px;
			}
			#{ selector }.graph:after {
				top: 0px; left: #{ @width / 2 - 0.5 }px;
				width: 1px; height: 100%;
			}
			#{ selector }.graph .ball {
				position: absolute;
				top:  #{ @height / 2 - 7.5 }px; 
				left: #{ @width / 2 - 7.5 }px;
				width: 15px; height: 15px;
				background-color: #333;
				border: solid 1px #222;
				border-radius: 3px; box-sizing: border-box;
				z-index: 1;         cursor: pointer;
			}
		".replace(/(\t|\n)/g, '')

		return style

	##
	# 要素の生成
	# @param style: stylesheet
	##
	createElement: (style) -> 
		app = "
			<div class=\"graph\">
				<div class=\"ball\"></div>
			</div>
			<style>#{style}</style>";

		return app

	##
	# イベントの紐付け
	##
	bindEvent: ->
		down = false

		# mousedown ------------------------------
		@ball.addEventListener 'mousedown', (e) =>
			rect = @ball.getBoundingClientRect()
			down =
				x: e.clientX - rect.left
				y: e.clientY - rect.top

		# mousemove ------------------------------
		window.addEventListener 'mousemove', (e) =>
			if down is false
				return

			width  = @width - 15
			height = @height - 15
			rect   = @graph.getBoundingClientRect()
			x      = e.clientX - rect.left - down.x
			y      = e.clientY - rect.top - down.y

			if x < 0 # x
				x = 0
			else if x > width
				x = width
			if y < 0 # y
				y = 0
			else if y > height
				y = height

			_x = x / width
			_y = y / height

			@move _x, _y
			@emit 'change', { x: _x, y: _y }

		# mouseup --------------------------------
		window.addEventListener 'mouseup', (e) =>
			down = false

	##
	# ボールの移動
	# @param x: x座標の割合
	# @param y: y座標の割合
	##
	move: (x, y) ->
		@current = 
			x: x
			y: y

		_x = (@width - 15) * x
		_y = (@height - 15) * y

		@ball.style.left = _x + 'px'
		@ball.style.top  = _y + 'px'

module.exports = GraphUI
