class ParameterPanelUI
	constructor: (params) ->
		@app = params.app

		@width  = params.width
		@height = params.height

		@slider = {}
		@val    = {}

	##
	# 描画
	##
	render: ->
		style = @createStyle()
		app   = @createElement style
		@app.innerHTML = app

		@p_panel_box = @app.children[1].children[0]

	##
	# スタイルシートの生成
	##
	createStyle: ->
		style = "
			.p-panel-tab {
				border-bottom: 25px solid #292929;
			    border-left: 15px solid transparent;
			    border-right: 15px solid transparent;
			    width: 80px; height: 0;
			    font-size: 10px; color: #595DEF;
			    line-height: 25px; text-align: center;
			    z-index: 0; cursor: pointer;
			    margin-top: 5px;
			}
			#parameter-panel .inner {
				width: 100%; height: #{ @height - 35 }px;
				background-color: #292929; padding: 5px 0;
				box-sizing: border-box;
			}
			.p-panel-box {
				width: 100%; height: #{ @height - 45 }px;
				overflow: auto;
			}
			.p-panel-box .param-li {
				width: 220px; padding: 9.5px;
				border-bottom: solid 1px #111;
				margin: 0 auto;
			}
			.p-panel-box .param-li[data-state=\"active\"] {
				background-color: #111;
			}
			.p-panel-box .param-li:after {
				content: \"\"; display: block; clear: both;
			}
			.p-panel-box .param-li .param-li-name {
				float: left;
				font-size: 10px; line-height: 20px;
				width: 50px; height: 20px; color: #ccc;
			}
			.p-panel-box .param-li .param-li-view {
				float: left;
			}
			.p-panel-box .param-li .param-li-val {
				float: left;
				font-size: 10px; line-height: 20px;
				text-align: right; color: #ccc;
				width: 30px; height: 20px;
			}
		".replace(/(\t|\n)/g, '')

		return style

	##
	# 要素の生成
	# @param style: スタイルシート
	##
	createElement: (style) ->
		app = "
			<div class=\"p-panel-tab\">parameter</div>
			<div class=\"inner\">
				<div class=\"p-panel-box\"></div>
			</div>
			<style>#{ style }</style>"

		return app

	##
	# 更新
	##
	reload: ->
		@p_panel_box.innerHTML = ''

		# パラメータ追加
		for key, param of app_json.parameter
			@addParameter({
				name: key
				type: param.type
			})

		app_state.setState 'current_parameter', 'default'

		# 時間の更新
		app_state.setState 'current_time', app_state.current_time

	##
	# パラメータの追加
	# @param params:
	##
	addParameter: (params) ->
		@off() # 選択解除

		p_li = document.createElement 'section'
		x    = app_state.parameter[params.name].x.toFixed 2
		y    = app_state.parameter[params.name].y
		if y isnt undefined
			y = y.toFixed 2

		p_li.className = 'param-li'
		p_li.innerHTML = "
			<h3 class=\"param-li-name\">#{ params.name }</h3>
			<div class=\"param-li-view\"></div>
			<p class=\"param-li-val\">#{ x }</p>
			<p class=\"param-li-val\">#{ y }</p>"
		p_li.setAttribute 'data-name', params.name
		p_li.setAttribute 'data-type', params.type
		p_li.setAttribute 'data-state', 'active'
		@p_panel_box.appendChild p_li

		# ビュー
		view = p_li.children[1]
		val1 = p_li.children[2]
		val2 = p_li.children[3]
		if params.type is 2 or params.type is 3
			@setSlider({ # スライダー
				name: params.name
				view: view
				val:  val1
			})
			val2.style.display = 'none'
		else
			@setGraph({  # グラフ
				name: params.name
				view: view
				val1: val1
				val2: val2
			})

		# mousedown --------------------------------------------
		p_li.onmousedown = (e) =>
			name = p_li.getAttribute 'data-name'
			app_state.setState 'current_parameter', name

		# contextmenu ------------------------------------------
		p_li.oncontextmenu = (e) =>
			UI.context_menu.render()
			UI.context_menu.setMenu([
				{
					text:     '消去'
					callback: @deleteParameter
				}
			], e.clientX, e.clientY)

		app_state.setState 'current_parameter', params.name

	##
	# スライダーの設置
	# @param params: name & view & val
	##
	setSlider: (params) ->
		slider = new Component.Slider({
			app:   params.view
			width: 140
		})
		slider.render()
		slider.on 'change', (x) =>
			time      = app_state.current_time
			keyframes = app_state.current_keyframes
			parameter = app_state.current_parameter

			if keyframes isnt false
				if not UI.timeline.checkActive()
					@slider[parameter].move 0.5
					return
				else
					num = UI.timeline.getNumber time
					app_json.keyframes[keyframes][parameter][num].x = x

			params.val.innerHTML = x.toFixed 2
			app_state.parameter[parameter] = { x: x }
			app_state.setState 'parameter', app_state.parameter
			UI.parameter_info.check x

		@slider[params.name] = slider
		@val[params.name]    = [params.val]

	##
	# グラフの設置
	# @param name & view & val1 & val2
	##
	setGraph: (params) ->
		graph = new Component.Graph({
			app:    params.view
			width:  140
			height: 60
		})
		graph.render()
		graph.on 'change', (p) =>
			time      = app_state.current_time
			keyframes = app_state.current_keyframes
			parameter = app_state.current_parameter

			if keyframes isnt false
				if not UI.timeline.checkActive()
					@slider[parameter].move 0.5, 0.5
				else
					num = UI.timeline.getNumber time
					app_json.keyframes[keyframes][parameter][num].x = p.x
					app_json.keyframes[keyframes][parameter][num].y = p.y

			params.val1.innerHTML = p.x.toFixed 2
			params.val2.innerHTML = p.y.toFixed 2
			app_state.parameter[parameter] = { x: p.x, y: p.y }
			app_state.setState 'parameter', app_state.parameter

			UI.parameter_info.check p.x, p.y

		@slider[params.name] = graph
		@val[params.name]    = [params.val1, params.val2]

	##
	# 選択解除
	##
	off: ->
		child = @p_panel_box.children

		for li in child
			li.setAttribute 'data-state', ''

	##
	# 選択
	# @param name: パラメータ名
	##
	active: (name) ->
		@off() # 選択解除

		child = @p_panel_box.children
		for li in child
			_name = li.getAttribute 'data-name'
			if name is _name
				li.setAttribute 'data-state', 'active'
				return

	##
	# パラメータの消去
	##
	deleteParameter: ->
		parameter = app_state.current_parameter
		child     = UI.parameter_panel.p_panel_box.children

		if parameter is 'default' # デフォルトは弾く
			return

		for li in child # 要素の消去
			name = li.getAttribute 'data-name'
			if parameter is name
				UI.parameter_panel.p_panel_box.removeChild(li)
				break

		for layer, i in app_json.layer # レイヤー情報から消去
			for key of layer.parameter
				if parameter is key
					delete app_json.layer[i].parameter[key]
					break

		for key, val of app_json.keyframes # アプリ状態情報から消去
			for _key, _val of val
				if parameter is _key
					delete app_json.keyframes[key][_key]
					break

		delete UI.parameter_panel.slider[parameter]
		delete UI.parameter_panel.val[parameter]
		delete app_state.parameter[parameter]
		delete app_json.parameter[parameter]

		app_state.setState 'current_parameter', 'default'
		UI.parameter_panel.active 'default'
		UI.history.pushHistory()

module.exports = ParameterPanelUI
