class Status
	constructor: (app) ->
		@app = app

	##
	# 描画
	##
	render: ->
		style = @createStyle()
		app   = @createElement style
		@app.innerHTML = app

		@mouse = @app.children[0].children[0]
		@scale = @app.children[0].children[1]
		@pos   = @app.children[0].children[2]
		@mode  = @app.children[0].children[3]

		@setMouse 0, 0
		@setMode app_state.mode
		@setScale app_state.scale
		@setPos app_state.position.x, app_state.position.y

		@bindEvent() # イベントの紐付け

	##
	# スタイルシートの生成
	##
	createStyle: ->
		style = "
			.status {
				font-size: 10px; color: #ccc;
				width: 100%; height: 30px;
			}
			.status:after {
				content: \"\"; display: block; clear: both;
			}
			.status section { float: left; }
			.status section:after {
				content: \"\"; display: block; clear: both;
			}
			.status .status-li {
				float: left;
				height: 30px;
				text-align: center;
				line-height: 30px;
				margin-left: 20px;
			}
			.status .status-li span {
				color: #D67C6A;
				margin-left: 5px;
			}
		".replace(/(\t|\n)/g, '')

	##
	# 要素の生成
	# @param style: スタイルシート
	##
	createElement: (style) ->
		app = "
			<div class=\"status\">
				<section>
					<div class=\"status-li status-x\"></div>
					<div class=\"status-li status-y\"></div>
				</section>
				<section>
					<div class=\"status-li status-scale\"></div>
				</section>
				<section>
					<div class=\"status-li status-pos-x\"></div>
					<div class=\"status-li status-pos-y\"></div>
				</section>
				<section>
					<div class=\"status-li status-mode\"></div>
				</section>
			</div>
			<style>#{ style }</style>"

		return app

	##
	# イベントの紐付け
	##
	bindEvent: ->
		window.addEventListener 'mousemove', (e) =>
			rect  = UI.view.view.getBoundingClientRect()
			x     = e.clientX - rect.left
			y     = e.clientY - rect.top
			_x    = x / UI.view.width
			_y    = y / UI.view.height

			if _x < 0 or _x > 1 or _y < 0 or _y > 1
				return

			@setMouse _x, _y


	##
	# マウス位置
	# @param x: x座標
	# @param y: y座標
	##
	setMouse: (x, y) ->
		mouse_x = @mouse.children[0]
		mouse_y = @mouse.children[1]
		x       = x.toFixed 2
		y       = y.toFixed 2

		mouse_x.innerHTML = 'mouse_x:<span>' + x + '</span>'
		mouse_y.innerHTML = 'mouse_y:<span>' + y + '</span>'

	##
	# モード変更
	# @param mode: モード
	##
	setMode: (mode) ->
		_mode = @mode.children[0]
		_mode.innerHTML = 'mode:<span>' + mode + '</span>'

	##
	# スケール変更
	# @param scale: スケール
	##
	setScale: (scale) ->
		_scale = @scale.children[0]
		_scale.innerHTML = 'scale:<span>' + scale.toFixed(2) + '</span>'

	##
	# 位置
	# @param x: x座標
	# @param y: y座標
	##
	setPos: (x, y) ->
		pos_x = @pos.children[0]
		pos_y = @pos.children[1]
		x       = x.toFixed 2
		y       = y.toFixed 2

		pos_x.innerHTML = 'pos_x:<span>' + x + '</span>'
		pos_y.innerHTML = 'pos_y:<span>' + y + '</span>'

module.exports = Status