class AddParameterViewUI
	constructor: (app) ->
		@app = app

		@listeners = {}

	##
	# 描画
	##
	render: ->
		style = @createStyle()
		app   = @createElement style
		@app.innerHTML = app

		@view      = @app.children[0]
		@bar       = @view.children[0]
		@close_btn = @bar.children[0]
		@box       = @view.children[1]
		@p_name    = @box.children[0]
		@p_type    = @box.children[1]
		@add_btn   = @box.children[2]

		@bindEvent() # イベントの紐付け

	##
	# スタイルシートの生成
	##
	createStyle: ->
		style = "
			.add-parameter-view {
				position: fixed;
				top: 100px; left: 520px;
				width: 250px;
				background-color: #4c4c4c;
				z-index: 10;
				border-radius: 5px;
				border: solid 1px #222;
			}
			.add-parameter-view .p-bar {
				position: relative;
				width: 100%; height: 20px;
				border-bottom: solid 1px #222;
				font-size: 12px; line-height: 20px;
				text-align: center; color: #999;
				background-color: #333;
				border-top-left-radius: 5px;
				border-top-right-radius: 5px;
			}
			.add-parameter-view .p-bar .close {
				position: relative;
				width: 20px; height: 20px;
				cursor: pointer;
			}
			.add-parameter-view .p-bar .close:before,
			.add-parameter-view .p-bar .close:after {
				position: absolute;
				top: 9.5px; left: 2.5px;
				content: \"\"; display: block;
				width: 15px; height: 1px;
				background-color: #ccc;
			}
			.add-parameter-view .p-bar .close:before { transform: rotate(45deg); }
			.add-parameter-view .p-bar .close:after { transform: rotate(-45deg); }
			.add-parameter-view .p-name {
				width: 230px; height: 30px;
				margin: 0 auto; display: block;
				margin-top: 10px;
				background-color: #393939;
				font-size: 10px; color: #ccc;
				box-sizing: border-box; padding: 0 5px;
			}
			.add-parameter-view .p-name:focus { outline: none; }
			.add-parameter-view .p-form {
				width: 230px; 
				margin: 0 auto; margin-top: 10px;
			}
			.add-parameter-view .p-form .p-type {
				width: 230px; height: 30px;
				background-color: #393939;
				margin-bottom: 5px;
				font-size: 10px; color: #ccc;
				line-height: 30px; text-align: center;
				cursor: pointer;
			}
			.add-parameter-view .p-form .p-type:after {
				content: \"\"; display: block; clear: both;
			}
			.add-parameter-view .p-form .p-type .check {
				float: left; 
				width: 20px; height: 20px;
				background-color: #222;
				border-radius: 3px;
				margin: 5px 0;
				margin-left: 5px;
			}
			.add-parameter-view .p-form .p-type .check[data-state=\"active\"] {
				background-image: url(../img/assets/check.png);
				background-size: 60%;
				background-position: center;
				background-repeat: no-repeat;
			}
			.add-parameter-view .p-form .p-type .name {
				float: right; 
				width: 195px; height: 20px;
				background-color: #222;
				margin: 5px 0;
				font-size: 10px; line-height: 20px;
				margin-right: 5px;
			}
			.add-parameter-view .add-btn {
				width: 230px; height: 30px;
				font-size: 10px; color: #ccc;
				line-height: 30px; text-align: center;
				margin: 10px auto; border-radius: 3px;
				background-color: #595DEF;
			}
		".replace(/(\t|\n)/g, '')

		return style

	##
	# 要素の生成
	##
	createElement: (style) ->
		app = "
			<div class=\"add-parameter-view\">
				<div class=\"p-bar\">
					<div class=\"close\"></div>
				</div>
				<div class=\"p-box\">
					<input type=\"text\" class=\"p-name\" 
						placeholder=\"parameter_name（8char）\" 
						maxlength=\"8\" />
					<div class=\"p-form\">
						<section class=\"p-type\">
							<div class=\"check\"
								data-state=\"active\"
								data-val=\"2\"></div>
							<div class=\"name\">2点パラメータ</div>
						</section>
						<section class=\"p-type\">
							<div class=\"check\"
								data-state=\"\"
								data-val=\"4\"></div>
							<div class=\"name\">4点パラメータ</div>
						</section>
						<section class=\"p-type\">
							<div class=\"check\"
								data-state=\"\"
								data-val=\"3\"></div>
							<div class=\"name\">回転パラメータ</div>
						</section>
					</div>
					<div class=\"add-btn\">add</div>
				</div>
			</div>
			<style>#{ style }</style>"

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
		@eventClose()  # 閉じる
		@eventWindow() # ウィンドウ移動
		@eventType()   # パラメータタイプの変更
		@eventAdd()    # パラメータ追加

	##
	# 閉じるのイベント
	## 
	eventClose: ->
		@close_btn.addEventListener 'click', (e) =>
			@close()

	##
	# ウィンドウの移動
	##
	eventWindow: ->
		down = false

		# mousedown ---------------------------------
		@bar.addEventListener 'mousedown', (e) =>
			rect = e.target.getBoundingClientRect()
			down = {
				x: e.clientX - rect.left
				y: e.clientY - rect.top
			}

		# mousemove ---------------------------------
		window.addEventListener 'mousemove', (e) =>
			if not down
				return

			x = e.clientX - down.x
			y = e.clientY - down.y

			if y < 20
				y = 20

			@view.style.top = y + 'px'
			@view.style.left = x + 'px'

		# mouseup ----------------------------------
		window.addEventListener 'mouseup', (e) =>
			down = false

	##
	# パラメータタイプの変更
	##
	eventType: ->
		types = @p_type.children

		for type in types
			type.children[0].addEventListener 'click', (e) =>
				for type in types
					type.children[0].setAttribute 'data-state', ''

				e.target.setAttribute 'data-state', 'active'

	##
	# パラメータ追加のイベント
	##
	eventAdd: () ->
		@add_btn.addEventListener 'click', (e) =>
			name = @p_name.value
			type = parseInt @getType()

			# 英数字
			if not name.match(/^[a-zA-Z0-9]+$/)
				alert '英数字で入力してください'
				return

			# 文字数
			if name.length <= 0 or name.length > 8
				alert '8文字以内で入力してください'
				return

			# 重複
			for key, parameter of app_json.parameter
				if key is name
					alert 'すでに同じ名前のパラメータが存在しています'
					return

			@emit 'add', { name: name, type: type }
			@close()

	##
	# パラメータタイプの取得
	##
	getType: ->
		types = @p_type.children

		for type in types
			state = type.children[0].getAttribute 'data-state'
			val   = type.children[0].getAttribute 'data-val'
			if state is 'active'
				return val

	##
	# 閉じる
	##
	close: ->
		@view.style.display = 'none'

module.exports = AddParameterViewUI
	
