class LayerPanelUI
	constructor: (params) ->
		@app = params.app

		@width =  params.width
		@height = params.height

		@cells     = []
		@hand_cell = null
		@axis_hand = null
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

		@layer_panel = @app.children[0]

		@bindEvent() # イベントの紐付け

	##
	# スタイルシートの生成
	##
	createStyle: ->
		style = "
			#data-panel .inner {
				position: relative;
				width: #{ @width }px; 
				height: #{ @height }px;
				box-sizing: border-box;
			}
			.layer-panel { 
				position: absolute; 
				top: 5px; left: 5px;
				width: #{ @width - 10 }px; 
				height: #{ @height - 10 }px; 
				overflow: auto;
			}
			.no-layer { width: 100%; height: 100%; display: table; }
			.no-layer p {
				font-size: 14px; color: #777; text-align: center;
				display: table-cell; vertical-align: middle;
			}
			.no-layer p i { margin-right: 5px; }
			.layer-cell {
				position: absolute;
				width: 249px; height: 50px;
				border-bottom: solid 1px #000;
				box-sizing: border-box;
				background-color: #292929; z-index: 0;
			}
			.layer-cell[data-select=\"true\"] {
				background-color: rgb(0,130,255); z-index: 1;
			}
			.layer-cell .layer-check-btn {
				position: absolute;
				top: 17.5px; left: 10px;
				width: 15px; height: 15px;
				background-color: #444;
				border-radius: 3px; cursor: pointer;
			}
			.layer-cell .layer-check-btn[data-state=\"show\"] {
				background-image: url(../img/assets/check.png);
				background-size: 90%;
				background-position: center;
				background-repeat: no-repeat;
			}
			.layer-cell .layer-thumb {
				position: absolute;
				top: 5px; left: 35px;
				width: 50px; height: 40px;
				background-color: #444;
				background-position: center;
				background-size: contain;
				background-repeat: no-repeat;
			}
			.layer-cell .layer-name {
				position: absolute;
				top: 5px; right: 10px;
				width: 145px; height: 40px;
				background-color: #444;
				font-size: 12px;
				color: #ccc;
				line-height: 40px;
				padding: 0 10px;
				box-sizing: border-box;
				font-weight: normal;
				overflow: hidden;
			}
			.layer-cell .layer-name span {
				display: inline-block;
				width: 16px;
				height: 12px;
				margin-right: 5px;
				background-image: url(../img/tool/image.png);
				background-size: 100%;
				background-position: center;
				background-repeat: no-repeat;
		}
		".replace(/(\t|\n)/g, '')

		return style

	##
	# 要素の生成
	# @param style: スタイルシート
	##
	createElement: (style) ->
		app = "
			<div class=\"layer-panel\">
				<div class=\"no-layer\">
					<p><i>There</i><i>is</i><i>no</i><i>layer.</i></p>
				</div>
			</div>
			<style>#{ style }</style>"

		return app

	##
	# イベントの紐付け
	##
	bindEvent: ->
		# mousemove -------------------------------------------
		window.addEventListener 'mousemove', (e) =>
			if @hand_cell is null
				return

			cell_pos = @cells[@hand_cell].pos
			scroll   = @layer_panel.scrollTop
			top      = @layer_panel.getBoundingClientRect().top
			pos      = e.pageY + scroll - top - @axis_hand
			max      = (app_json.layer.length - 1) * 50

			# 位置制御
			if pos < 0
				pos = 0
			else if pos > max
				pos = max

			if (pos - cell_pos) > 25 # レイヤーを下げる
				layer = @cells[@hand_cell].num
				next  = @.nextCell layer, 'down'

				@cells[@hand_cell].num -= 1
				@cells[@hand_cell].pos += 50
				@cells[next].num       += 1
				@cells[next].pos       -= 50
				@cells[next].repos()
			else if (pos - cell_pos) < -25 # レイヤーを上げる
				layer = @cells[@hand_cell].num
				next  = @.nextCell layer, 'up'

				@cells[@hand_cell].num += 1
				@cells[@hand_cell].pos -= 50
				@cells[next].num       -= 1
				@cells[next].pos       += 50
				@cells[next].repos()

			# 選択レイヤーの更新
			_layer = @cells[@hand_cell].num
			app_state.setState 'current_layer', _layer

			@cells[@hand_cell].move pos # セルの移動 

		# mouseup ---------------------------------------------
		window.addEventListener 'mouseup', (e) =>
			if @hand_cell is null
				return

			@cells[@hand_cell].repos()
			@hand_cell = null

	##
	# 次のセル番号の取得
	# @param num:  セル番号
	# @param type: up or down
	## 
	nextCell: (num, type) ->
		if type is 'up'
			num += 1
		else if type is 'down'
			num -= 1

		for i in [0..@cells.length - 1]
			if num is @cells[i].num
				return i

	##
	# セルの選択
	##
	selectCell: ->
		layer = app_state.current_layer
		for i in [0..@cells.length - 1]
			_layer  = @cells[i].num
			if layer is _layer
				@cells[i].selectCell true
			else 
				@cells[i].selectCell false

	##
	# レイヤーパネルの消去
	##
	delete: ->
		@app.removeChild @layer_panel

	##
	# レイヤーパネルの更新
	##
	reload: ->
		length = app_json.layer.length
		@cells = [];
		@layer_panel.innerHTML = ''

		if length <= 0 # レイヤーがない
			@nolayer()
			app_state.setState 'current_layer', 0
			return

		for i in [0..app_json.layer.length - 1]
			directory = app_state.directory
			show      = app_json.layer[i].show
			name      = app_json.layer[i].name
			url       = app_json.layer[i].url

			@addCell {
				active: show
				name:   name
				img:    "file://#{ directory + url }"
			}
		app_state.setState 'current_layer', length - 1 # 選択レイヤーの更新

	##
	# セルの追加
	# @param params: 
	##
	addCell: (params) ->
		num = @cells.length
		if num is 0
			@layer_panel.innerHTML = ''

		@repos() # 位置の再配置

		@cells.push new Component.LayerCell({
			app:    @layer_panel
			active: params.active
			num:    num
			pos:    0
			img:    params.img
			name:   params.name
		})
		@cells[num].render()

		for i in [0..@cells.length - 1]
			@cells[i].move @cells[i].pos

		layer_check_btn = @cells[num].layer_check_btn
		layer_cell      = @cells[num].layer_cell

		# チェック ----------------------------------------------
		layer_check_btn.addEventListener 'click', (e) =>
			num = parseInt e.target.parentNode.getAttribute 'data-num'
			@cells[num].check()

			app_state.setState 'current_layer', app_state.current_layer

		# 移動 -------------------------------------------------
		layer_cell.addEventListener 'mousedown', (e) =>
			num   = parseInt layer_cell.getAttribute 'data-num'
			layer = parseInt layer_cell.getAttribute 'data-layer'
			top   = @cells[num].layer_cell.getBoundingClientRect().top

			@hand_cell = num
			@axis_hand = e.pageY - top

			app_state.setState 'current_layer', layer

		# コンテキストメニュー -----------------------------------
		layer_cell.addEventListener 'contextmenu', (e) =>
			layer = parseInt layer_cell.getAttribute 'data-layer'
			num   = parseInt layer_cell.getAttribute 'data-num'

			UI.context_menu.render()
			UI.context_menu.setMenu([
				{
					text: '消去'
					callback: ->
						# レイヤー消去
						app_json.layer.splice layer, 1

						# レイヤーパネルの更新
						UI.layer_panel.deleteCell num
						UI.layer_panel.reload()

						# 選択レイヤーの更新
						app_state.setState 'current_layer', 0

						# 履歴の更新
						UI.history.pushHistory()
				}
			], e.clientX, e.clientY)

	##
	# 位置の再配置
	##
	repos: ->
		length = @cells.length - 1
		if length < 0
			return

		for i in [length..0]
			n = @cells.length - @cells[i].num
			@cells[i].pos = n * 50

	##
	# セルの消去
	##
	deleteCell: (num) ->
		@cells[num].delete()
		this.cells.splice num, 1

		if app_json.layer.length <= 0
			@nolayer()

	##
	# no layer パネル
	##
	nolayer: ->
		@layer_panel.innerHTML = "
			<div class=\"no-layer\">
				<p><i>There</i><i>is</i><i>no</i><i>layer.</i></p>
			</div>"

module.exports = LayerPanelUI