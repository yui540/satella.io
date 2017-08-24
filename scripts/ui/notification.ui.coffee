class NotificationUI
	constructor: (app) ->
		@app = app

	##
	# 描画
	##
	render: ->
		style = @createStyle()
		app   = @createElement style

		@app.innerHTML = app

		@notification = @app.children[0]
		@message      = @notification.children[1]

	##
	# 要素の生成
	##
	createElement: (style) ->
		app = "
			<div class=\"notification\">
				<div class=\"icon\"></div>
				<div class=\"message\"></div>
			</div>
			<style>#{ style }</style>"

		return app

	##
	# スタイルシートの生成
	##
	createStyle: ->
		style = "
			.notification {
				position: fixed;
				top: 10px; right: -202px;
				width: 200px; height: 50px;
				background-color: #222;
				border: solid 1px #666;
				border-radius: 5px;
				z-index: 10;
			}
			.notification[data-state=\"active\"] {
				animation: on 2.5s ease 0s;
			}
			.notification:after {
				content: \"\"; display: block; clear: both;
			}
			.notification .icon {
				float: left;
				width: 50px; height: 50px;
				background-image: url(../img/assets/notification.png);
				background-size: 40%;
				background-position: center;
				background-repeat: no-repeat;
			}
			.notification .message {
				float: right;
				width: 150px; height: 50px;
				font-size: 12px; color: #ccc;
				text-align: center;
				line-height: 50px;
			}
			@keyframes on {
				0%   { right: -202px; }
				20%  { right: 10px; }
				80%  { right: 10px; }
				100% { right: -202px; }
			}
		".replace(/(\t|\n)/g, '')

		return style

	##
	# 通知の発火
	##
	emit: (message) ->
		@message.innerHTML = message
		@notification.setAttribute 'data-state', 'active'

		setTimeout(() => 
			@notification.setAttribute 'data-state', ''
		, 3000)

module.exports = NotificationUI