class PutKeyframeUI 
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

		@back_point     = @app.children[0]
		@put_keyframe   = @app.children[1]
		@forward_point  = @app.children[2]

		@bindEvent() # イベントの紐付け

	##
	# スタイルシートの生成
	##
	createStyle: ->
		style = "
			.point-btn {
				float: left;
				width: 20px; height: 25px;
				margin-left: 1px;
				background-color: #444;
				background-position: center;
			    background-repeat: no-repeat;
			    background-size: auto 80%;
			    cursor: pointer;
			}
			.point-btn:first-child {
				border-top-left-radius: 3px;
				border-bottom-left-radius: 3px;
				margin-left: 10px;
			}
			.put-keyframe {
				width: 50px;
			    background-image: url(../img/keyframes/keyframes.png);
			    background-size: auto 90%;
			}
			.back-point {
			    background-image: url(../img/keyframes/back-point.png);
			}
			.forward-point {
			    background-image: url(../img/keyframes/go-point.png);
			    border-top-right-radius: 3px;
				border-bottom-right-radius: 3px;
			}
		".replace(/(\t|\n)/g, '')

	##
	# 要素の生成
	##
	createElement: (style) ->
		app = "
			<div class=\"back-point point-btn\"></div>
			<div class=\"put-keyframe point-btn\"></div>
			<div class=\"forward-point point-btn\"></div>
			<style>#{ style }</style>"

		return app

	##
	# イベントの紐付け
	##
	bindEvent: ->
		@eventBack()    # 後ろのポイントに戻る
		@eventForward() # 前のポイントに進む
		@eventPut()     # ポイントに配置

	##
	# 後ろのポイントに戻る
	##
	eventBack: ->
		# click ---------------------------------------------
		@back_point.addEventListener 'click', (e) =>
			time1     = app_state.current_time
			keyframes = app_state.current_keyframes
			parameter = app_state.current_parameter

			if keyframes is false # アニメーション選択されているか
				return

			points = app_json.keyframes[keyframes][parameter]

			length = points.length - 1
			for i in [length..0]
				time2 = points[i].time
				if time1 > time2
					app_state.setState 'current_time', time2
					return

		# mouseover -----------------------------------------
		@back_point.addEventListener 'mouseover', (e) =>
			UI.help.render({
				title:       'BackPoint'
				description: '一つ後ろのポイントに戻ります。'
				x:           e.clientX
				y:           e.clientY
			})

		# mouseout ------------------------------------------
		@back_point.addEventListener 'mouseout', (e) =>
			UI.help.remove()

	##
	# 前のポイントに進む
	##
	eventForward: ->
		# click ---------------------------------------------
		@forward_point.addEventListener 'click', (e) =>
			time1     = app_state.current_time
			keyframes = app_state.current_keyframes
			parameter = app_state.current_parameter

			if keyframes is false # アニメーション選択されているか
				return

			points = app_json.keyframes[keyframes][parameter]

			for point in points
				time2 = point.time
				if time1 < time2
					app_state.setState 'current_time', time2
					return

		# mouseover -----------------------------------------
		@forward_point.addEventListener 'mouseover', (e) =>
			UI.help.render({
				title:       'ForwardPoint'
				description: '一つ前のポイントに進みます。'
				x:           e.clientX
				y:           e.clientY
			})

		# mouseout ------------------------------------------
		@forward_point.addEventListener 'mouseout', (e) =>
			UI.help.remove()

	##
	# ポイントに配置
	##
	eventPut: ->
		# click ---------------------------------------------
		@put_keyframe.addEventListener 'click', (e) =>
			time      = app_state.current_time
			keyframes = app_state.current_keyframes
			parameter = app_state.current_parameter
			type      = app_json.parameter[parameter].type
			point     = {}

			if keyframes is false
				return
			else if not @checkTime time
				return

			points = app_json.keyframes[keyframes][parameter]
			m      = getMiddleVal points, type

			# ポイント情報
			point      = copy m
			point.time = time

			# ポイント追加
			app_json.keyframes[keyframes][parameter].push point

			# ソート
			app_json.keyframes[keyframes][parameter] = @sort points

			@emit 'put'

		# mouseover ------------------------------------------
		@put_keyframe.addEventListener 'mouseover', (e) =>
			UI.help.render({
				title:       'PutPoint'
				description: '現在の時間にポイントを追加します。'
				x:           e.clientX
				y:           e.clientY
			})

		# mouseout -------------------------------------------
		@put_keyframe.addEventListener 'mouseout', (e) =>
			UI.help.remove()

	##
	# 時間順にソート
	##
	sort: (points) ->
		_points = copy points

		return _points.sort (a, b) => 
			if a.time > b.time
				return 1
			else
				return -1

	##
	# 時間に重複がないかチェック
	# @param time: 時間
	##
	checkTime: (time) ->
		keyframes = app_state.current_keyframes
		parameter = app_state.current_parameter
		points    = app_json.keyframes[keyframes][parameter]

		for point in points
			_time = point.time
			if time is _time
				return false
		return true

module.exports = PutKeyframeUI
