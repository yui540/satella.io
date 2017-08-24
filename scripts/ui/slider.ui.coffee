class SliderUI
	constructor: (params) -> 
		@app    = params.app
		@slider = null
		@bar    = null
		@picker = null

		@width     = params.width
		@current   = 0.5
		@color     = '#595DEF'
		@listeners = {}

	##
	# 描画
	##
	render: -> 
		style = @createStyle()
		app   = @createElement style
		@app.innerHTML = app

		@slider = @app.children[0]
		@bar    = @slider.children[0]
		@picker = @slider.children[1]

		@bindEvent() # イベントの紐付け
		
	##
	# スタイルシートの生成
	##
	createStyle: ->
		pos      = @current * (@width - 12)
		bar      = @current * 100
		selector = ''

		if @app.classList[0] isnt undefined
			selector = '.' + @app.classList[0] + ' '
		else if @app.id isnt undefined
			selector = '#' + @app.id + ' '

		style = "
			#{ selector }.slider {
				position: relative;
				margin-top: 8px;
				width: #{ @width }px;
				height: 3px;
				background-color: #999;
			}
			#{ selector }.slider .bar {
				position: absolute;
				width: #{bar}%; height: 3px;
				background-color: #{ @color };
			}
			#{ selector }.slider .picker {
				position: absolute;
				top: -6px;   left: #{pos}px;
				width: 12px; height: 16px;
				border-radius: 3px;
				cursor: pointer;
				border: solid 1px #333;
				box-sizing: border-box;
				background-color: #444;
			}
		".replace(/(\t|\n)/g, '')

		return style

	##
	# 要素の生成
	# @param style: stylesheet
	##
	createElement: (style) ->
		app = "
			<div class=\"slider\">
				<div class=\"bar\"></div>
				<div class=\"picker\"></div>
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
	bindEvent: -> 
		down = false

		# mousedown ---------------------------------
		@picker.addEventListener 'mousedown', (e) => 
			rect = @slider.getBoundingClientRect()
			down = rect.left

		# mousemove ---------------------------------
		window.addEventListener 'mousemove', (e) => 
			if down is false
				return

			x = e.clientX - down
			if x > @width
				x = @width
			else if x < 0
				x = 0
			x = x / @width

			@move x
			@emit 'change', @current

		# mouseup -----------------------------------
		window.addEventListener 'mouseup', (e) => 		
			down = false

	##
	# ピックの移動
	# @param x: x座標の割合
	##
	move: (x) ->
		@current = x
		width    = @current * 100
		left     = @current * (@width - 12)

		@bar.style.width   = width + '%'
		@picker.style.left = left + 'px'

module.exports = SliderUI