class ControlsUI
	constructor: (app) ->
		@app = app

		@height = SIZE['CONTROLS-PANEL'].HEIGHT

	##
	# 描画
	##
	render: ->
		style = @createStyle()
		app   = @createElement style
		@app.innerHTML = app

		@controls_panel   = @app.children[0]
		@scale_controls   = @controls_panel.children[1]
		@pos_controls     = @controls_panel.children[2]
		@default_controls = @controls_panel.children[3]

		# スライダー
		@scale_slider = new Component.Slider({
			app:   @scale_controls.children[1],
			width: 175
		})
		@scale_slider.render()
		@setScale app_state.scale

		# グラフ
		@pos_graph = new Component.Graph({
			app:    @pos_controls
			width:  239
			height: @height - 120
		})
		@pos_graph.render()

		@bindEvent() # イベントの紐付け

	##
	# スタイルシートの生成
	##
	createStyle: ->
		style = "
			.controls-panel {
				width: 260px;
				height: #{ @height }px;
				border-top: solid 1px #4c4c4c;
				border-right: solid 1px #4c4c4c;
				box-sizing: border-box;
				background-color: #292929;
			}
			.controls-title {
				width: 259px; height: 30px;
				font-size: 11px; color: #595DEF;
				line-height: 30px; text-align: center;
				border-bottom: solid 1px #4c4c4c;
			}
			.scale-controls {
				width: 239px; height: 40px;
				margin: 0 auto;
			}
			.scale-controls:after {
				content: \"\"; display: block; clear: both;
			}
			.scale-controls .li { 
				float: left; height: 40px;
				text-align: center; font-size: 10px;
				line-height: 40px; color: #ccc;
			}
			.scale-controls .scale-name { width: 39px; }
			.scale-controls .scale-slider { width: 175px; }
			.scale-controls .scale-slider .slider {
				margin-top: 18px;
			}
			.scale-controls .scale-val { 
				width: 25px; text-align: right;
			}
			.pos-controls {
				width: 259px;
				height: #{ @height - 110 }px;
			}
			.pos-controls .graph {
				margin-left: 10px;
			}
			.default-controls {
				width: 239px; height: 30px;
				margin: 0 auto;
			}
			.default-controls:after {
				content: \"\"; display: block; clear: both;
			}
			.default-controls .default-scale,
			.default-controls .default-pos {
				float: left;
				width: 114.5px; height: 30px;
				background-color: #444;
				border-radius: 3px; cursor: pointer;
				font-size: 10px; text-align: center;
				line-height: 30px; color: #ccc;
			}
			.default-controls .default-scale {
				margin-right: 10px;
			}
		".replace(/(\t|\n)/g, '')

		return style

	##
	# 要素の生成
	# @param style: スタイルシート
	##
	createElement: (style) ->
		app = "
			<div class=\"controls-panel\">
				<section class=\"controls-title\">
					controls
				</section>
				<section class=\"scale-controls\">
					<div class=\"scale-name li\">scale</div>
					<div class=\"scale-slider li\"></div>
					<div class=\"scale-val li\"></div>
				</section>
				<section class=\"pos-controls\"></section>
				<section class=\"default-controls\">
					<div class=\"default-scale\">
						default_scale
					</div>
					<div class=\"default-pos\">
						default_position
					</div>
				</section>
			</div>
			<style>#{ style }</style>"

		return app

	##
	# イベントの紐付け
	##
	bindEvent: ->
		@eventScale()        # スケール
		@eventPos()          # 位置
		@eventDefaultScale() # デフォルトのスケール
		@eventDefaultPos()   # デフォルトの位置

	##
	# スケールのイベント
	## 
	eventScale: ->
		@scale_slider.on 'change', (x) =>
			scale = x * 6
			@setScale scale

	##
	# 位置イベント
	##
	eventPos: ->
		@pos_graph.on 'change', (val) =>
			x = val.x
			y = val.y

			app_state.setState 'position', { x: x, y: y }

	##
	# デフォルトスケールイベント
	##
	eventDefaultScale: ->
		# click ---------------------------------------------
		@default_controls.children[0].addEventListener 'click', (e) =>
			@setScale 1.0, 1.0

		# mouseover -----------------------------------------
		@default_controls.children[0].addEventListener 'mouseover', (e) =>
			UI.help.render({
				title:       'DefaultScale'
				description: 'デフォルトのズームに戻します。(0.5)'
				x:           e.clientX
				y:           e.clientY
			})

		# mouseout ------------------------------------------
		@default_controls.children[0].addEventListener 'mouseout', (e) =>
			UI.help.remove()

	##
	# デフォルト位置に移動イベント
	##
	eventDefaultPos: ->
		# click ---------------------------------------------
		@default_controls.children[1].addEventListener 'click', (e) =>
			@setMove 0.5, 0.5

		# mouseover -----------------------------------------
		@default_controls.children[1].addEventListener 'mouseover', (e) =>
			UI.help.render({
				title:       'DefaultPosition'
				description: 'デフォルトの位置に戻します。(0.5,0.5)'
				x:           e.clientX
				y:           e.clientY
			})

		# mouseout ------------------------------------------
		@default_controls.children[1].addEventListener 'mouseout', (e) =>
			UI.help.remove()

	##
	# スケールの変更
	# @param scale: スケール
	##
	setScale: (scale) ->
		@scale_slider.move scale / 6
		@scale_controls.children[2].innerHTML = scale.toFixed 2
		app_state.setState 'scale', scale

	##
	# 位置の変更
	# @param x: x座標
	# @param y: y座標
	##
	setMove: (x, y) ->
		@pos_graph.move x, y
		app_state.setState 'position', { x: x, y: y }

module.exports = ControlsUI