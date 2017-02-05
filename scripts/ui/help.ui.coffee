class HelpUI
	constructor: (app) ->
		@app = app

	##
	# 描画
	##
	render: (params) ->
		style = @createStyle()
		params['style'] = style
		app = @createElement params
		@app.appendChild app

		@help = @app.children[0]

		@setPos(params.x, params.y) # 位置設定

	##
	# スタイルシートの生成
	## 
	createStyle: ->
		style = "
			.help {
				position: fixed;
				width: 120px;
				background-color: #393939;
				padding: 5px;
				box-sizing: border-box;
				border: solid 1px #222;
				border-radius: 5px;
				z-index: 15;
			}
			.help .title {
				font-size: 12px;
				font-weight: normal;
				border-bottom: solid 1px #888;
				color: #D67C6A;
				margin-bottom: 5px;
			}
			.help .description {
				font-size: 10px;
				color: #888;
			}
		".replace(/(\t|\n)/g, '')

		return style

	##
	# 要素の生成
	# @param params: title & description & x & y & style
	##
	createElement: (params) ->
		app = document.createElement 'div'
		app.className     = 'help'
		app.style.opacity = 0

		title = document.createElement 'h3'
		title.className = 'title'
		title.innerHTML = params.title

		description = document.createElement 'p'
		description.className = 'description'
		description.innerHTML = params.description

		style = document.createElement 'style'
		style.innerHTML = params.style

		app.appendChild title
		app.appendChild description
		app.appendChild style

		return app

	##
	# 位置設定
	# @param x: x座標
	# @param y: y座標
	## 
	setPos: (x, y) ->
		height = window.innerHeight / 2
		w      = @help.getBoundingClientRect().width / 2
		h      = @help.getBoundingClientRect().height

		x -= w

		if y < height # 上
			y += 10
		else          # 下
			y -= h + 10

		@help.style.top     = y + 'px'
		@help.style.left    = x + 'px'
		@help.style.opacity = 1

	##
	# 消去
	##
	remove: ->
		@app.innerHTML = ''

module.exports = HelpUI