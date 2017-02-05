class ProjectPanelUI
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

		@project_panel = @app.children[0]

	##
	# スタイルシートの生成
	##
	createStyle: ->
		style = "
			.project-panel {
				position: absolute; 
				top: 5px; left: 5px;
				width: #{ @width - 10 }px; 
				height: #{ @height - 10 }px; 
				background-color: #292929;
				overflow: auto; z-index: 1;
			}
			.project-content .project-content-li {
				width: 220px; margin: 0 auto;
				font-size: 10px; text-align: right; color: #D67C6A;
				background-color: #4c4c4c; padding: 5px;
				box-sizing: border-box; border-radius: 3px;
			}
			.project-content .project-content-li p {
				text-align: left; margin-bottom: 5px;
				color: #ccc; border-bottom: solid 1px #ccc;
			}
			.project-content .thumb {
				width: 100px; height: 100px;
				background-size: 100%;
				background-position: center;
				margin: 0 auto; background-color: #4c4c4c;
				border-radius: 5px;
			}
			.project-layer-title {
				width: 70px; height: 70px;
				border-radius: 50%; line-height: 70px;
				font-size: 12px; text-align: center;
				color: #ccc; font-weight: normal; 
				background-color: #4c4c4c; margin: 0 auto;
			}
			.project-layer-li {
				width: 220px;
				margin: 0 auto;
				padding: 5px; box-sizing: border-box;
				background-color: #4c4c4c; border-radius: 3px;
			}
			.project-layer-li p {
				font-size: 10px; color: #ccc;
			}
			.project-layer-li p span {
				margin-left: 10px; color: #D67C6A;
			}
			.ver-line {
				width: 1px; height: 20px;
				background-color: #4c4c4c;
				margin: 0 auto;
			}
		".replace(/(\t|\n)/g, '')

		return style

	##
	# 要素の生成
	# @param style: スタイルシート
	##
	createElement: (style) ->
		app = "
			<div class=\"project-panel\"></div>
			<style>#{ style }</style>"

		return app

	##
	# 表示
	##
	open: ->
		@project_panel.style.display = 'block'

	##
	# 非表示
	##
	close: ->
		@project_panel.style.display = 'none'

	##
	# プロジェクト情報の更新
	##	
	reload: ->
		@project_panel.innerHTML = ''

		@setContent()   # 作品情報
		@setLayer()     # レイヤー情報
		@setParameter() # パラメータ情報
		@setKeyframes() # アニメーション情報

	##
	# 作品情報の設置
	##
	setContent: ->
		dir          = app_state.directory
		author       = app_json.author
		content_name = app_json.content_name
		description  = app_json.description
		tag          = app_json.tag

		@project_panel.innerHTML += "
			<div class=\"project-content\">
				<div class=\"ver-line\"></div>
				<h3 class=\"project-layer-title\">meta</h3>
				<div class=\"ver-line\"></div>
				<div class=\"project-content-li\">
					<p>author:</p>
					#{ author }
				</div>
				<div class=\"ver-line\"></div>
				<div class=\"project-content-li\">
					<p>content_name:</p>
					#{ content_name }
				</div>
				<div class=\"ver-line\"></div>
				<div class=\"project-content-li\">
					<p>description:</p>
					#{ description }
				</div>
				<div class=\"ver-line\"></div>
				<div class=\"project-content-li\">
					<p>tag:</p>
					#{ tag }
				</div>
				<div class=\"ver-line\"></div>
				<div class=\"project-content-li\">
					<p>directory:</p>
					#{ dir }
				</div>
				<div class=\"ver-line\"></div>
			</div>"

	##
	# レイヤー情報の表示
	##
	setLayer: ->
		layer = app_json.layer

		if layer.length <= 0
			return

		ele   = "
			<h3 class=\"project-layer-title\">layer</h3>
			<div class=\"ver-line\"></div>"

		for i in [layer.length - 1..0]
			ele += "
				<section class=\"project-layer-li\">
					<p>name:<span>#{ layer[i].name }</span></p>
					<p>url:<span>#{ layer[i].url }</span></p>
					<p>mesh:<span>#{ layer[i].mesh }</span></p>
					<p>show:<span>#{ layer[i].show }</span></p>
					<p>quality:<span>#{ layer[i].quality }</span>
					<p>parameter:"
			for key, val of layer[i].parameter
				ele += "<span>#{ key }</span>"

			ele += "</p></section>"
			ele += "<div class=\"ver-line\"></div>"

		@project_panel.innerHTML += ele

	##
	# パラメータ情報の表示
	##
	setParameter: ->
		parameter = app_json.parameter
		ele       = "
			<h3 class=\"project-layer-title\">parameter</h3>
			<div class=\"ver-line\"></div>"

		for key, val of parameter
			type  = val.type
			layer = val.layer

			ele += "
				<section class=\"project-layer-li\">
					<p>name:<span>#{ key }</span></p>
					<p>type:<span>#{ type }</span></p>"

			ele += "</p></section>"
			ele += "<div class=\"ver-line\"></div>"

		@project_panel.innerHTML += ele

	##
	# アニメーション情報の表示
	##
	setKeyframes: ->
		keyframes = app_json.keyframes
		ele       = "
			<h3 class=\"project-layer-title\">keyframes</h3>
			<div class=\"ver-line\"></div>"

		for key, val of keyframes
			name = key
			parameter = val

			ele += "
				<section class=\"project-layer-li\">
					<p>name:<span>#{ name }</span></p>"

			ele += "</p></section>"
			ele += "<div class=\"ver-line\"></div>"

		@project_panel.innerHTML += ele

module.exports = ProjectPanelUI