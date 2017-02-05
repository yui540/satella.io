class ToolUI
	constructor: (app) ->
		@app = app

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

		@tool          = @app.children[0]
		@add_param_btn = @tool.children[0]
		@image_btn     = @tool.children[1]
		@sdk_btn       = @tool.children[2]
		@save_btn      = @tool.children[3]

		@bindEvent() # イベントの紐付け

	##
	# スタイルシートの生成
	##
	createStyle: ->
		style = "
			.tool {
				width: 100%; height: 25px;
				margin-top: 10px;
			}
			.tool:after {
				content: \"\"; display: block; clear: both;
			}
			.tool .tool-li {
				float: left;
				width: 40px; height: 25px;
				background-size: auto 80%;
				background-repeat: no-repeat;
				background-position: center;
				background-color: #393939;
				border-radius: 3px;
				margin-left: 20px;
				cursor: pointer;
			}
			.tool .add-param {
				background-image: url(../img/tool/param.png);
			}
			.tool .sdk {
				background-image: url(../img/tool/sdk.png);
			}
			.tool .save {
				background-image: url(../img/tool/save.png);
			}
			.tool .image {
				background-image: url(../img/tool/image.png);
			}
		".replace(/(\t|\n)/g, '')

		return style

	##
	# 要素の生成
	# @param style: スタイルシート
	##
	createElement: (style) ->
		app = "
			<div class=\"tool\">
				<div class=\"tool-li add-param\"></div>
				<div class=\"tool-li image\">
					<input type=\"file\" accept=\"image/*\" style=\"display:none\" />
				</div>
				<div class=\"tool-li sdk\"></div>
				<div class=\"tool-li save\"></div>
			</div>
			<style>#{ style }</style>"

		return app

	##
	# イベントの紐付け
	##
	bindEvent: ->
		@eventParam()   # パラメータの追加
		@eventSDK()     # SDKの作成
		@eventSave()    # 保存
		@eventTexture() # テクスチャ

	##
	# パラメータの追加
	##
	eventParam: ->
		# click ---------------------------------------------
		@add_param_btn.addEventListener 'click', (e) =>
			UI.add_parameter.render()

		# add -----------------------------------------------
		UI.add_parameter.on 'add', (params) =>
			app_json.parameter[params.name] = {
				layer: []
				type:  params.type
			}

			if params.type is 4 # 4点パラメータ
				app_state.parameter[params.name] = {
					x: 0.5
					y: 0.5
				}
			else                # 回転・2点パラメータ
				app_state.parameter[params.name] = {
					x: 0.5
				}

			UI.parameter_panel.reload()
			UI.project_panel.reload()
			UI.history.pushHistory() # 履歴の更新

		# mouseover -----------------------------------------
		@add_param_btn.addEventListener 'mouseover', (e) =>
			UI.help.render({
				title:       'AddParameter'
				description: '２点パラメータ<br />4点パラメータ<br />回転パラメータ<br />の中から選択し、パラメータを追加します。'
				x:           e.clientX
				y:           e.clientY
			})

		# mouseout ------------------------------------------
		@add_param_btn.addEventListener 'mouseout', (e) =>
			UI.help.remove()

	##
	# SDKの作成
	## 
	eventSDK: ->
		# click ---------------------------------------------
		@sdk_btn.addEventListener 'click', (e) =>
			ipcRenderer.send 'sdk'

		# ipc -----------------------------------------------
		ipcRenderer.on 'sdk', (event) =>
			UI.notification.emit 'SDK作成完了'

		# mouseover -----------------------------------------
		@sdk_btn.addEventListener 'mouseover', (e) =>
			UI.help.render({
				title:       'SDK'
				description: '指定の場所にSDKキットを生成します。'
				x:           e.clientX
				y:           e.clientY
			})

		# mouseout ------------------------------------------
		@sdk_btn.addEventListener 'mouseout', (e) =>
			UI.help.remove()

	##
	# 保存
	##
	eventSave: ->
		# click ---------------------------------------------
		@save_btn.addEventListener 'click', (e) =>
			UI.save.write()
			UI.thumb.save () =>
				UI.notification.emit '保存完了'

		# mouseover -----------------------------------------
		@save_btn.addEventListener 'mouseover', (e) =>
			UI.help.render({
				title:       'Save'
				description: 'プロジェクトを保存します。'
				x:           e.clientX
				y:           e.clientY
			})

		# mouseout ------------------------------------------
		@save_btn.addEventListener 'mouseout', (e) =>
			UI.help.remove()

	##
	# テクスチャの追加
	##
	eventTexture: ->
		_params = {}

		# click ---------------------------------------------
		@image_btn.addEventListener 'click', (e) =>
			@image_btn.children[0].click()
			@image_btn.children[0].onchange = (e) =>
				file = @image_btn.children[0].files[0]
				UI.save_texture.create file

		# create --------------------------------------------
		UI.save_texture.on 'create', (data) =>
			_params.data = data
			UI.image_view.render _params.data

		# add -----------------------------------------------
		UI.image_view.on 'add', (params) =>
			_data        = _params.data
			_params      = copy params
			_params.data = _data 

			UI.save_texture.recreate _params

		# recreate ------------------------------------------
		UI.save_texture.on 'recreate', (data) =>
			_params.data = data
			@emit 'add', _params # イベント発火

			UI.image_view.delete()
			_params = {}

		# mouseover -----------------------------------------
		@image_btn.addEventListener 'mouseover', (e) =>
			UI.help.render({
				title:       'AddTexture'
				description: 'テクスチャの追加をします。'
				x:           e.clientX
				y:           e.clientY
			})

		# mouseout ------------------------------------------
		@image_btn.addEventListener 'mouseout', (e) =>
			UI.help.remove()
	
module.exports = ToolUI