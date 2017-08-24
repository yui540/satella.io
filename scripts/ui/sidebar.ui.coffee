class SideBarUI
	constructor: (app) ->
		@app = app

	##
	# 描画
	##
	render: ->
		style = @createStyle()
		app   = @createElement style
		@app.innerHTML = app

		@sidebar = @app.children[0]

		# ウィンドウの描画
		@add_keyframes = new AddKeyframes document.getElementById 'add-keyframes-view'
		@add_keyframes.render()

	##
	# スタイルシートの生成
	##
	createStyle: ->
		style = "
			.sidebar {}
			.sidebar .sidebar-li {
				width: 30px; height: 30px;
				border-radius: 50%;
				background-color: #ccc;
				margin: 0 auto; cursor: pointer;
				font-size: 14px; color: #4c4c4c;
				text-align: center; line-height: 30px;
			}
			.sidebar .sidebar-li[data-state=\"active\"] {
				color: #ccc;
				background-color: #595DEF;
			}
			.sidebar .line {
				width: 1px; height: 10px;
				background-color: #ccc;
				margin: 0 auto;
			}
			.sidebar .add-btn {
				position: relative;
				width: 30px; height: 30px;
				border-radius: 50%;
				background-color: #ccc;
				margin: 0px auto; cursor: pointer;
			}
			.sidebar .add-btn:before,
			.sidebar .add-btn:after {
				position: absolute;
				content: \"\"; display: block;
				background-color: #4c4c4c;
			}
			.sidebar .add-btn:before {
				top: 14px; left: 5px; width: 20px; height: 2px;
			}
			.sidebar .add-btn:after {
				top: 5px; left: 14px; width: 2px; height: 20px;
			}
			.sidebar .add-btn:first-child { margin-top: 10px; }

			.sidebar .unselected-btn {
				position: relative;
				width: 30px; height: 30px;
				border-radius: 50%;
				background-color: #ccc;
				margin: 0px auto; cursor: pointer;
			}
			.sidebar .unselected-btn:after {
				position: absolute;
				content: \"\"; display: block;
				background-color: #4c4c4c;
				top: 14px; left: 5px; width: 20px; height: 2px;
			}
		".replace(/(\t|\n)/g, '')

		return style

	##
	# 要素の生成
	##
	createElement: (style) ->
		app = "
			<div class=\"sidebar\"></div>
			<style>#{ style }</style>"

		return app

	##
	# 更新
	##
	reload: ->
		@sidebar.innerHTML = ''

		@drawAddBtn()      # 追加ボタン
		@drawUnselectBtn() # 非選択ボタン

		for key of app_json.keyframes
			name = key.toString()
			@draw name

		length = @sidebar.children.length - 1
		child  = @sidebar.children[length]
		@sidebar.removeChild child

		this.check() # 選択

	##
	# 追加ボタンの描画
	##
	drawAddBtn: ->
		add_btn = document.createElement 'div'
		add_btn.className = 'add-btn'
		add_btn.onclick   = (e) =>
			@add_keyframes.open()

		line    = document.createElement 'div'
		line.className = 'line'

		@sidebar.appendChild add_btn
		@sidebar.appendChild line

	##
	# 非選択ボタンの描画
	##
	drawUnselectBtn: ->
		unsel_btn = document.createElement 'div'
		unsel_btn.className = 'unselected-btn'
		unsel_btn.onclick   = (e) =>
			app_state.setState 'current_keyframes', false
			@check()

		line = document.createElement 'div'
		line.className = 'line'

		@sidebar.appendChild unsel_btn
		@sidebar.appendChild line

	##
	# キーフレームリストの描画
	# @param name: アニメーション名
	# @param flg: 
	##
	draw: (name, flg) ->
		list = document.createElement 'section'
		list.className = 'sidebar-li'
		list.innerHTML = name[0].toUpperCase() + name[1].toLowerCase()
		list.setAttribute 'data-state', '' 
		list.setAttribute 'data-name', name

		line = document.createElement 'div'
		line.className = 'line'

		# click ----------------------------------------------
		list.onclick = (e) =>
			name = e.target.getAttribute 'data-name'

			app_state.setState 'current_keyframes', name
			@check()

		# contextmenu ----------------------------------------
		list.oncontextmenu = (e) =>
			name = e.target.getAttribute 'data-name'
			if name is 'default'
				return

			UI.context_menu.render()
			UI.context_menu.setMenu([
				{
					text: '消去'
					callback: =>
						delete app_json.keyframes[name]

						app_state.setState 'current_keyframes', false
						@reload()
				}
			])

		@sidebar.appendChild list
		@sidebar.appendChild line

	check: ->
		list = @sidebar.children

		for li in list
			name     = li.getAttribute 'data-name'
			_name    = app_state.current_keyframes
			selector = li.className

			if selector isnt 'sidebar-li'
				continue
			else if name is _name
				li.setAttribute 'data-state', 'active'
			else
				li.setAttribute 'data-state', ''

class AddKeyframes
	constructor: (app) ->
		@app = app

	##
	# 描画
	##
	render: ->
		style = @createStyle()
		app   = @createElement style
		@app.innerHTML = app

		@view      = @app.children[0]
		@header    = @view.children[0]
		@close_btn = @header.children[0]
		@body      = @view.children[1]
		@ani_name  = @body.children[0]
		@add_btn   = @body.children[1]

		@bindEvent() # イベントの紐付け

	##
	# スタイルシートの生成
	##
	createStyle: ->
		style = "
			.add-keyframes-view {
				position: fixed; 
				top: 60px; right: 50px;
				width: 250px; background-color: #4c4c4c;
				z-index: 10; border: solid 1px #222;
				border-radius: 5px; display: none;
			}
			.add-keyframes-view .header {
				width: 100%; height: 20px;
				background-color: #333;
				border-bottom: solid 1px #222;
				border-top-left-radius: 5px;
				border-top-right-radius: 5px;
			}
			.add-keyframes-view .header .close {
				position: relative;
				width: 20px; height: 20px;
				cursor: pointer;
			}
			.add-keyframes-view .header .close:before,
			.add-keyframes-view .header .close:after {
				position: absolute;
				top: 9.5px; left: 2.5px;
				content: \"\"; display: block;
				width: 15px; height: 1px;
				background-color: #ccc;
			}
			.add-keyframes-view .header .close:before { 
				transform: rotate(45deg); 
			}
			.add-keyframes-view .header .close:after { 
				transform: rotate(-45deg); 
			}
			.add-keyframes-view .body {}
			.add-keyframes-view .body .ani-name {
				display: block; width: 230px; height: 30px;
				background-color: #666;
				margin: 10px auto; padding: 0 5px;
				box-sizing: border-box; color: #ccc;
			}
			.add-keyframes-view .body .ani-name:focus { outline: none; }
			.add-keyframes-view .body .add-btn {
				width: 100px; height: 25px;
				background-color: #595DEF;
				margin-bottom: 10px; margin-left: 140px;
				border-radius: 3px; font-size: 12px;
				color: #ccc; line-height: 25px;
				text-align: center;
			}
		".replace(/(\t|\n)/g, '')

		return style

	##
	# 要素の生成
	# @param style: スタイルシート
	##
	createElement: (style) ->
		app = "
			<div class=\"add-keyframes-view\">
				<section class=\"header\">
					<div class=\"close\"></div>
				</section>
				<section class=\"body\">
					<input type=\"text\" placeholder=\"アニメーション名(20字以内)\" 
						maxlength=\"20\" class=\"ani-name\" />
					<div class=\"add-btn\">add</div>
				</section>
			</div>
			<style>#{ style }</style>"

		return app
	
	##
	# イベントの紐付け
	##
	bindEvent: ->
		@eventClose() # アニメーション追加
		@eventAdd()   # 閉じる

	##
	# 閉じるのイベント
	##
	eventClose: ->
		@close_btn.addEventListener 'click', (e) =>
			@ani_name.value = ''
			@close()

	##
	# 追加のイベント
	##
	eventAdd: ->
		@add_btn.addEventListener 'click', (e) =>
			ani_name = @ani_name.value

			# 英数字
			if not ani_name.match(/^[0-9a-z]+$/)
				alert '英数字で入力してください'
				return

			# 文字数
			if ani_name.length < 2 or ani_name.length > 20
				alert '2〜20文字以内で入力してください'
				return

			# 重複
			for key, val of app_json.keyframes
				name = key.toString()
				if name is ani_name
					alert 'すでに同じ名前のアニメーションは存在します'
					return

			@close()
			@ani_name.value = ''
			app_json.keyframes[ani_name] = {}
			UI.notification.emit 'アニメーション追加'
			UI.sidebar.reload()

	##
	# 表示
	##
	open: ->
		@view.style.display = 'block'

	##
	# 非表示
	##
	close: ->
		@view.style.display = 'none'

module.exports = SideBarUI