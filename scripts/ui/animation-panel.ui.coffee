class AnimationPanelUI
	constructor: (app) ->
		@app = app

		@timer = null
	
	##
	# 描画
	##
	render: ->
		style = @createStyle()
		app   = @createElement style
		@app.innerHTML = app

		@animation_panel = @app.children[0]
		@timepanel       = @animation_panel.children[0]
		@animation_name  = @timepanel.children[0]
		@time            = @timepanel.children[1]
		@play_controls   = @animation_panel.children[1]

		@setTime parseInt app_state.current_time
		@setAnimation app_state.current_keyframes
		@bindEvent() # イベントの紐付け

	##
	# スタイルシートの描画
	##
	createStyle: ->
		style = "
			.animation-panel {
				width: 260px; height: 70px;
			}
			.animation-panel section {
				width: 100%;  height: 35px;
			}
			.animation-panel section:after {
				content: \"\"; display: block; clear: both;
			}

			.animation-panel .timepanel {
				border-bottom: solid 1px #4c4c4c;
				box-sizing: border-box;
			}
			.animation-panel .timepanel .time {
				float: left;
				width: 130px; height: 35px;
				font-size: 18px; color: #ccc;
				text-align: center; line-height: 35px;
			}
			.animation-panel .timepanel .animation-name {
				float: left;
				width: 129px; height: 35px;
				font-size: 12px; color: #595DEF;
				text-align: center; line-height: 35px;
				border-right: solid 1px #4c4c4c;
			}

			.animation-panel .play-controls {}
			.play-controls .play-li {
				float: left;
				width: 70px; height: 25px;
				border-radius: 3px;
				background-position: center;
				background-size: auto 60%;
				background-repeat: no-repeat;
				margin-top: 5px; cursor: pointer;
				margin-left: 12.5px;
			}
			.play-controls .play-li:hover {
				background-color: #4c4c4c;
			}
			.play-controls .play-min {
				background-image: url(../img/controls/min.png);
			}
			.play-controls .play-main {
				background-image: url(../img/controls/play.png);
			}
			.play-controls .play-max {
				background-image: url(../img/controls/max.png);
			}
		".replace(/(\t|\n)/g, '')

		return style

	##
	# 要素の生成
	# @param style: スタイルシート
	##
	createElement: (style) ->
		app = "
			<div class=\"animation-panel\">
				<section class=\"timepanel\">
					<div class=\"animation-name\"></div>
					<div class=\"time\"></div>
				</section>
				<section class=\"play-controls\">
					<div class=\"play-li play-min\"></div>
					<div class=\"play-li play-main\" 
						data-state=\"\"></div>
					<div class=\"play-li play-max\"></div>
				</section>
			</div>
			<style>#{ style }</style>"

		return app

	##
	# イベントの紐付け
	##
	bindEvent: ->
		@eventMinBtn()  # 最小ボタン
		@eventPlayBtn() # 再生ボタン
		@eventMaxBtn()  # 最大ボタン

	##
	# 最小ボタン
	## 
	eventMinBtn: ->
		min = @play_controls.children[0]

		min.addEventListener 'click', (e) =>
			app_state.setState 'current_time', 0

	##
	# 最大ボタン
	## 
	eventMaxBtn: ->
		max = @play_controls.children[2]

		max.addEventListener 'click', (e) =>
			app_state.setState 'current_time', 20 * 60 - 1

	##
	# 再生・停止ボタン
	##
	eventPlayBtn: ->
		play_controls = @play_controls.children[1]

		play_controls.addEventListener 'click', (e) =>
			@check()

			state = e.target.getAttribute 'data-state'
			if state is 'active'
				app_state.setState 'play', true
				@play()
			else 
				app_state.setState 'play', false
				@pause()

	##
	# 再生
	##
	play: ->
		fps = 1000 / 60
		max = 20 * 60

		@timer = setInterval(() =>
			time = app_state.current_time + 1

			if max <= time
				time = 0

			app_state.setState 'current_time', time
		, fps)

	##
	# 停止
	##
	pause: ->
		clearInterval @timer

	##
	# チェック
	##
	check: ->
		play_controls = @play_controls.children[1]
		play          = 'url(../img/controls/play.png)'
		pause         = 'url(../img/controls/pause.png)'
		state         = play_controls.getAttribute 'data-state'

		if state is 'active'
			play_controls.style.backgroundImage = play
			play_controls.setAttribute 'data-state', ''
		else
			play_controls.style.backgroundImage = pause
			play_controls.setAttribute 'data-state', 'active'

	##
	# アニメーション名の設置
	# @param ani_name: アニメーション名
	##
	setAnimation: (ani_name) ->
		if not ani_name
			ani_name = '<span style="color:#ccc">not</span>'

		@timepanel.children[0].innerHTML = ani_name

	##
	# 現在時間の設置
	# @param time: 時間
	##
	setTime: (time) ->
		timepanel = @timepanel.children[1]
		sec       = Math.floor time / 60
		mili      = time - 60 * sec

		sec  = @createTime sec
		mili = @createTime mili

		timepanel.innerHTML = sec + ':' + mili

	##
	# 時間の生成
	# @param time: 整数
	##
	createTime: (time) ->
		if time < 10
			time = '0' + time
		else
			time = '' + time

		return time

module.exports = AnimationPanelUI
				