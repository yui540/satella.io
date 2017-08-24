class ParameterInfoUI
	constructor: (params) ->
		@app = params.app

		@width  = params.width
		@height = params.height

	##
	# 描画
	##
	render: ->
		style = @createStyle()
		app   = @createElement style
		@app.innerHTML = app

		@p_info_tab = @app.children[0]
		@p_info_box = @app.children[1].children[0]

	##
	# スタイルシートの生成
	##
	createStyle: ->
		style = "
			.p-info-tab {
				border-bottom: 25px solid #292929;
			    border-left: 15px solid transparent;
			    border-right: 15px solid transparent;
			    width: 80px; height: 0;
			    font-size: 10px; color: #595DEF;
			    line-height: 25px; text-align: center;
			    z-index: 0; cursor: pointer;
			    margin-top: 5px;
			}
			#parameter-info .inner {
				width: 100%; height: #{ @height - 25 }px;
				padding: 5px 0; background-color: #292929;
				box-sizing: border-box;
			}
			.p-info-box {
				width: 100%; height: #{ @height - 35 }px;
				overflow: auto;
			}
			.p-info-box .p-type-2 {
				position: relative;
				width: 230px; height: 35px;
				background-color: #444;
				margin: 0 10px;
			}
			.p-info-box .p-type-2:after {
				position: absolute;
				content: \"\"; display: block;
				background-color: #ccc;
				width: 100%; height: 1px;
				top: #{ 35 / 2 - 0.5 }px; left: 0;
			}
			.p-info-box .p-type-2 .p-type-2-li {
				position: absolute;
				width: 15px; height: 15px;
				background-color: #111; border-radius: 3px;
				z-index: 1; cursor: pointer;
			}
			.p-info-box .p-type-2 .p-type-2-li[data-state=\"active\"] {
				background-image: url(../img/assets/check.png);
				background-size: 80%;
				background-position: center;
				background-repeat: no-repeat;
			}
			.p-info-box .p-type-2 .p-type-2-0 {
				top: #{ 35 / 2 - 7.5 }px; left: #{ 230 / 2 - 7.5 }px;
			}
			.p-info-box .p-type-2 .p-type-2-1 {
				top: #{ 35 / 2 - 7.5 }px; left: 0;
			}
			.p-info-box .p-type-2 .p-type-2-2 {
				top: #{ 35 / 2 - 7.5 }px; left: 215px;
			}
			.p-info-box .p-type-4 {
				position: relative;
				width: 230px; height: 80px;
				background-color: #444;
				margin: 0 10px;
			}
			.p-info-box .p-type-4:before,
			.p-info-box .p-type-4:after {
				position: absolute;
				content: \"\"; display: block;
				background-color: #ccc;
			}
			.p-info-box .p-type-4:before {
				width: 100%; height: 1px;
				top: #{ 80 / 2 - 0.5 }px; left: 0;
			}
			.p-info-box .p-type-4:after {
				width: 1px; height: 100%;
				top: 0; left: #{ 230 / 2 - 0.5 }px;
			}
			.p-info-box .p-name {
				width: 230px;
				margin: 0px auto; margin-top: 5px;
				font-size: 14px;
				font-weight: normal;
				text-align: center; padding: 1px 0;
				color: #ccc; background-color: #222;
				border-bottom: solid 1px #444;
			}
			.p-info-box .p-type-4 .p-type-4-li {
				position: absolute;
				width: 15px; height: 15px;
				background-color: #111; border-radius: 3px;
				z-index: 1; cursor: pointer;
			}
			.p-info-box .p-type-4 .p-type-4-li[data-state=\"active\"] {
				background-image: url(../img/assets/check.png);
				background-size: 80%;
				background-position: center;
				background-repeat: no-repeat;
			}
			.p-info-box .p-type-4 .p-type-4-0 {
				top: #{ 80 / 2 - 7.5 }px; left: #{ 230 / 2 - 7.5 }px;
			}
			.p-info-box .p-type-4 .p-type-4-1 {
				top: #{ 80 / 2 - 7.5 }px; left: 0;
			}
			.p-info-box .p-type-4 .p-type-4-2 {
				top: #{ 80 / 2 - 7.5 }px; left: 214.5px;
			}
			.p-info-box .p-type-4 .p-type-4-3 {
				top: 0; left: #{ 230 / 2 - 7.5 }px;
			}
			.p-info-box .p-type-4 .p-type-4-4 {
				top: 65px; left: #{ 230 / 2 - 7.5 }px;
			}
			.p-info-box .p-layer-li {
				position: relative;
				width: 230px; height: 30px;
				background-color: #4c4c4c;
				margin: 0 auto; margin-bottom: 1px;
			}
			.p-info-box .p-layer-li:first-child { margin-top: 10px; }
			.p-info-box .p-layer-li .check-box {
				position: absolute;
				top: 7.5px; left: 5px;
				width: 15px; height: 15px;
				background-color: #111;
				border-radius: 3px; cursor: pointer;
			}
			.p-info-box .p-layer-li .check-box[data-state=\"active\"] {
				background-image: url(../img/assets/check.png);
			    background-size: 80%;
			    background-position: center;
			    background-repeat: no-repeat;
			}
			.p-info-box .p-layer-li .layer-name {
				position: absolute;
				top: 5px; left: 30px;
				width: 195px; height: 20px;
				background-color: #292929;
				font-size: 10px; color: #D67C6A;
				line-height: 20px; padding: 0 5px;
				box-sizing: border-box;
			}
		".replace(/(\t|\n)/g, '')

		return style

	##
	# 要素の生成
	# @param style: スタイルシート
	##
	createElement: (style) ->
		app = "
			<div class=\"p-info-tab\">infomation</div>
			<div class=\"inner\">
				<div class=\"p-info-box\"></div>
			</div>
			<style>#{ style }</style>"

		return app

	##
	# 選択中のパラメータ
	# @param params: type & name
	##
	active: (params) ->
		@p_info_box.innerHTML = ''
		p_name = document.createElement 'h3'
		p_name.className = 'p-name'
		p_name.innerHTML = params.name

		# 操作UI
		p_type = document.createElement 'div'
		if params.type is 4 # ４点パラメータ
			p_type.className = 'p-type-4'
			@setType4 params.name, p_type
		else                # 2点・回転パラメータ
			p_type.className = 'p-type-2'
			@setType2 params.name, p_type

		# ビューの表示
		@p_info_box.appendChild p_name
		@p_info_box.appendChild p_type

		# レイヤーの表示
		@setLayer p_type

		# 選択状態のチェック
		p = app_state.parameter[params.name]
		@check p.x, p.y

	##
	# 4点パラメータのグラフ設置
	# @param name:   パラメータ名
	# @param p_type: 要素
	##
	setType4: (name, p_type) ->
		list = ['0.5,0.5', '0.0,0.5', '1.0,0.5', '0.5,0.0', '0.5,1.0']

		for i in [0..4] # 4点
			p_type_li = document.createElement 'section'
			p_type_li.className = "p-type-4-#{ i } p-type-4-li"
			p_type_li.setAttribute 'data-state', ''
			p_type_li.setAttribute 'data-val', list[i]
			p_type.appendChild p_type_li

			# click --------------------------------------------------
			p_type_li.onclick = (e) =>
				p = e.target.getAttribute('data-val').split ','
				x = parseFloat p[0]
				y = parseFloat p[1]

				# パラメータの更新
				app_state.parameter[name] = { x: x, y: y }
				app_state.setState 'parameter', app_state.parameter

				# ビューの更新
				UI.parameter_panel.slider[name].move x, y
				UI.parameter_panel.val[name][0].innerHTML = x.toFixed 2
				UI.parameter_panel.val[name][1].innerHTML = y.toFixed 2

				# 選択状態の確認
				@check x, y

	##
	# 2点・回転パラメータのスライダー設置
	# @param name:   パラメータ名
	# @param p_type: 要素
	##
	setType2: (name, p_type) ->
		list = ['0.5,0.5', '0.0,0.5', '1.0,0.5', '0.5,0.0', '0.5,1.0']

		for i in [0..2] # ２点
			p_type_li = document.createElement 'section'
			p_type_li.className = "p-type-2-#{ i } p-type-2-li"
			p_type_li.setAttribute 'data-state', ''
			p_type_li.setAttribute 'data-val', list[i].split(',')[0]
			p_type.appendChild p_type_li

			# click --------------------------------------------------
			p_type_li.onclick = (e) =>
				x = parseFloat e.target.getAttribute 'data-val'

				# パラメータの更新
				app_state.parameter[name] = { x: x }
				app_state.setState 'parameter', app_state.parameter

				# ビューの更新
				UI.parameter_panel.slider[name].move x 
				UI.parameter_panel.val[name][0].innerHTML = x.toFixed 2

				# 選択状態の確認
				@check x

	##
	# レイヤーの設置
	##
	setLayer: ->
		len = app_json.layer.length
		if len <= 0 # レイヤーがない
			return 

		p_layer = document.createElement 'div'
		p_layer.className = 'p-layer'

		for i in [0..len - 1] # レイヤー数
			layer_li = document.createElement 'div'
			layer_li.className = 'p-layer-li'
			layer_li.innerHTML = "
				<div class=\"check-box\"
					data-state=\"\"
					data-layer=\"#{ i }\"></div>
				<div class=\"layer-name\">
					#{ app_json.layer[i].name }</div>"

			# 登録確認
			for key, val of app_json.layer[i].parameter
				if key is app_state.current_parameter
					layer_li.children[0].setAttribute 'data-state', 'active'

			# click -----------------------------------------------
			layer_li.children[0].onclick = (e) =>
				name  = app_state.current_parameter
				type  = app_json.parameter[name].type
				state = e.target.getAttribute 'data-state'
				layer = parseInt e.target.getAttribute 'data-layer'

				if state is 'active'
					e.target.setAttribute 'data-state', ''
					delete app_json.layer[layer].parameter[name]
				else
					e.target.setAttribute 'data-state', 'active'
					UI.view.addParameter layer, type, name

				UI.history.pushHistory() # 履歴の更新

			p_layer.appendChild layer_li # 描画

		@p_info_box.appendChild p_layer

	##
	# 選択状態の確認
	# @param x: x
	# @param y: y
	##
	check: (x, y) ->
		n         = false
		p_type_li = @p_info_box.children[1]

		if y is undefined # 4点パラメータ
			if x is 0.5
				n = 0
			else if x is 0.0
				n = 1
			else if x is 1.0
				n = 2
		else                # ２点・回転パラメータ
			if x is 0.5 and y is 0.5
				n = 0
			else if x is 0.0 and y is 0.5
				n = 1
			else if x is 1.0 and y is 0.5
				n = 2
			else if x is 0.5 and y is 0.0
				n = 3
			else if x is 0.5 and y is 1.0
				n = 4

		@off p_type_li # 一旦、全て非選択
		if n is false
			return

		p_type_li.children[n].setAttribute 'data-state', 'active'
		return true

	##
	# 全てを非選択
	# @param p_type_li: ボタンのリスト
	##
	off: (p_type_li) ->
		li = p_type_li.children
		for type in li
			type.setAttribute 'data-state', ''

module.exports = ParameterInfoUI