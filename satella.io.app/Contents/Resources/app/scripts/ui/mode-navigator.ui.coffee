class ModeNavigator
	constructor: (app) ->
		@app = app

		@pos       = { x: 0, y: 0 }
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

		@mode_nagivator = @app.children[0]

		@bindEvent() # イベントの紐付け
	
	##
	# スタイルシートの生成
	##
	createStyle: ->
		style = "
			.nav-view {
				position: fixed;
				width: 150px;
				background-color: #111;
				border-radius: 5px;
				z-index: 5;
			}
			.nav-view .title {
				font-size: 10px;
				text-align: center;
				width: 100%; height: 20px;
				line-height: 20px;
				color: #ccc; border-bottom: solid 1px #4c4c4c;
			}
			.nav-view .pointer-box {
				width: 100%;
			}
			.nav-view .pointer-box:after {
				content: \"\"; display: block; clear: both;
			}
			.nav-view .pointer-box .pointer-li {
				float: left;
				width: 50%; height: 20px;
				font-size: 10px; color: #ccc;
				text-align: center;
				line-height: 20px;
			}
			.nav-view .pointer-box .pointer-li span {
				margin-left: 10px;
				color: #D67C6A;
			}
			.nav-view .pointer-box .pointer-one {
				width: 100%; height: 20px;
				font-size: 10px; color: #D67C6A;
				text-align: center;
				line-height: 20px;
			}
		".replace(/(\t|\n)/g, '')

		return style

	##
	# 要素の生成
	# @param style: スタイルシート
	##
	createElement: (style) ->
		app = "
			<div class=\"mode-nagivator\"></div>
			<style>#{ style }</style>"

		return app

	##
	# イベントの紐付け
	##
	bindEvent: ->
		@eventMouse()   # マウス位置
		@eventPointer() # Pointer
		@eventPolygon() # Polygon
		@eventCollect() # Collect
		@eventAnchor()  # Anchor
		@eventRotate()  # Rotate
		@eventCubism()  # Cubism
		@eventAtari()   # Atari
		@eventEnd()     # End

	##
	# マウス位置のイベント
	## 
	eventMouse: ->
		window.addEventListener 'mousemove', (e) =>
			@pos.x = e.clientX - 75
			@pos.y = e.clientY + 20

	##
	# Pointerのイベント
	##
	eventPointer: ->
		@on 'pointer', (params) =>
			@mode_nagivator.innerHTML = "
				<div class=\"nav-view\">
					<div class=\"title\">Pointer</div>
					<div class=\"pointer-box\">
						<div class=\"pointer-li\">
							x:<span>#{ params.x.toFixed 3 }</span>
						</div>
						<div class=\"pointer-li\">
							y:<span>#{ params.y.toFixed 3 }</span>
						</div>
					</div>
				</div>"

			@move @pos.x, @pos.y

	##
	# Polygonのイベント
	##
	eventPolygon: ->
		@on 'polygon', (params) =>
			

	##
	# Collectのイベント
	##
	eventCollect: ->
		@on 'collect', (params) =>
			

	##
	# Anchorのイベント
	##
	eventAnchor: ->
		@on 'anchor', (params) =>
			@mode_nagivator.innerHTML = "
				<div class=\"nav-view\">
					<div class=\"title\">Anchor</div>
					<div class=\"pointer-box\">
						<div class=\"pointer-li\">
							x:<span>#{ params.x.toFixed 3 }</span>
						</div>
						<div class=\"pointer-li\">
							y:<span>#{ params.y.toFixed 3 }</span>
						</div>
					</div>
				</div>"

			@move @pos.x + 90, @pos.y

	##
	# Rotateのイベント
	##
	eventRotate: ->
		@on 'rotate', (params) =>
			@mode_nagivator.innerHTML = "
				<div class=\"nav-view\">
					<div class=\"title\">Anchor</div>
					<div class=\"pointer-box\">
						<div class=\"point-one\">
							#{ params.toFixed 3 }
						</div>
					</div>
				</div>"

			@move @pos.x, @pos.y		

	##
	# Cubismのイベント
	##
	eventCubism: ->
		@on 'cubism', (params) =>
			@mode_nagivator.innerHTML = "
				<div class=\"nav-view\">
					<div class=\"title\">Cubism</div>
					<div class=\"pointer-box\">
						<div class=\"pointer-li\">
							x:<span>#{ params.x.toFixed 3 }</span>
						</div>
						<div class=\"pointer-li\">
							y:<span>#{ params.y.toFixed 3 }</span>
						</div>
					</div>
				</div>"

			@move @pos.x, @pos.y

	##
	# Atariのイベント
	##
	eventAtari: ->
		@on 'atari', (params) =>
			@mode_nagivator.innerHTML = "
				<div class=\"nav-view\">
					<div class=\"title\">Atari</div>
					<div class=\"pointer-box\">
						<div class=\"pointer-li\">
							x:<span>#{ params.x.toFixed 3 }</span>
						</div>
						<div class=\"pointer-li\">
							y:<span>#{ params.y.toFixed 3 }</span>
						</div>
					</div>
				</div>"

			@move @pos.x + 90, @pos.y

	##
	# Endのイベント
	##
	eventEnd: ->
		@on 'end', =>
			@mode_nagivator.innerHTML = ''

	##
	# 移動
	##
	move: (x, y) ->
		@mode_nagivator.children[0].style.left = x + 'px'
		@mode_nagivator.children[0].style.top  = y + 'px'

module.exports = ModeNavigator