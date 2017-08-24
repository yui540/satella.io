class ContextMenuUI
	constructor: (app) ->
		@app = app

	##
	# 描画
	##
	render: ->
		style = @createStyle()
		app   = @createElement style
		@app.innerHTML = app

		@context_menu = @app.children[0]
		@context_box  = @context_menu.children[0]

		@bindEvent() # イベントの紐付け

	##
	# スタイルシートの生成
	##
	createStyle: ->
		style = "
			.context-menu {
				position: fixed;
				top: 0; left: 0;
				width: 100%; height: 100%;
				z-index: 1000;
			}
			.context-menu .menu-box {
				position: absolute;
				top: 100px; left: 100px;
				box-shadow: 0 0 5px #4c4c4c;
				border-radius: 3px;
			}
			.context-menu .menu-box .menu-li {
				width: 150px; height: 25px;
				font-size: 10px; color: #222;
				line-height: 25px; padding-left: 10px;
				box-sizing: border-box;
				border-bottom: solid 1px #4c4c4c;
				background-color: #ccc;
			}
			.context-menu .menu-box .menu-li:first-child {
				border-top-left-radius: 3px;
				border-top-right-radius: 3px;
			}
			.context-menu .menu-box .menu-li:last-child {
				border-bottom-left-radius: 3px;
				border-bottom-right-radius: 3px;
				border-bottom: none;
			}
			.context-menu .menu-box .menu-li:hover {  
				background-color: #666;
				color: #fff; cursor: pointer;
			}
		".replace(/(\t|\n)/g, '')

		return style

	##
	# 要素の生成
	# @param style
	##
	createElement: (style) ->
		app = "
			<div class=\"context-menu\">
				<div class=\"menu-box\"></div>
			</div>
			<style>#{ style }</style>"

		return app

	##
	# イベントの紐付け
	##
	bindEvent: ->
		@context_menu.addEventListener 'click', (e) =>
			@delete()

	##
	# 消去
	##
	delete: ->
		@app.innerHTML = ''
		@context_menu  = null
		@context_box   = null

	##
	# メニューの設置
	##
	setMenu: (menu, x, y) ->
		@context_box.style.left = x + 5 + 'px'
		@context_box.style.top  = y - 7.5 + 'px'

		for li in menu
			menu_li = document.createElement 'section'
			menu_li.className = 'menu-li'
			menu_li.innerHTML = li.text
			menu_li.onclick   = li.callback
			
			@context_box.appendChild menu_li
	
module.exports = ContextMenuUI