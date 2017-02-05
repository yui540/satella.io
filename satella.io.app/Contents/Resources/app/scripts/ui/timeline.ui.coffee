class TimelineUI
	constructor: (app) ->
		@app = app

		@width      = 0
		@point_down = false
		@points     = []

	##
	# 描画
	# @param time: 時間
	##
	render: (time) ->
		style = @createStyle()
		app   = @createElement style
		@app.innerHTML = app

		@time      = time
		@timeline  = @app.children[0]
		@seek_pic  = @timeline.children[0]
		@time_bar  = @timeline.children[1]
		@keyframes = @timeline.children[2]

		@setBlock(@time) # 時間区切りの設置
		@bindEvent()     # イベントの紐付け

	##
	# スタイルシートの生成
	##
	createStyle: ->
		style = "
			.timeline { 
				position:relative; 
				top: 0; left: 0px;
				width: 2000px; height: 60px; 
			}
			.timeline .seek-pic {
				position: absolute; top: 0;
				width: 1px; height: 60px;
				background-color: #fff; z-index: 5;
			}
			.timeline .seek-pic[data-state=\"active\"] { 
				background-color: #ff0000;
			}
			.timeline .seek-pic[data-state=\"active\"] div {
				border: solid 1px #ff0000;
			}
			.timeline .seek-pic div {
				content: \"\"; display: block;
				position: absolute; top: 0; left: -5px;
				width: 10px; height: 10px;
				border: solid 1px #fff;
				cursor: pointer;
			}
			.timeline .time-bar { height: 30px; }
			.timeline .time-bar:before { 
				content: \"\"; display: block; clear: both; 
			}
			.timeline .time-bar .block {
				float: left;
				width: 60px; height: 20px;
				font-size: 10px; color: #777; line-height: 20px;
				box-sizing: border-box;
				padding: 0 5px; margin: 5px 0;
				border-right: solid 1px #555; }
			.timeline .keyframes {
				position: absolute; height: 30px;
			}
			.timeline .keyframes .point {
				position: absolute; top: 10px;
				width: 10px; height: 10px;
				background-color: #000; border: solid 3px #FFA500;
				box-sizing: border-box; border-radius: 2px;
				transform: rotate(45deg);
				z-index: 1; cursor: pointer;
			}
			.timeline .keyframes .label {
				position: absolute; top: 0px;
				font-size: 10px; color: #ccc;
				line-height: 30px; border-radius: 3px;
				border: solid 1px #555;
				box-sizing: border-box; padding: 0 10px;
				width: 100%; height: 30px;
				background-color: #556C88;
				z-index: 0;
			}
			.timeline .keyframes .label span {
				margin: 0 10px;
			}
		".replace(/(\t|\n)/g, '')

		return style

	##
	# 要素の生成
	# @param style: スタイルシート
	##
	createElement: (style) ->
		app = "
			<div class=\"timeline\">
				<div class=\"seek-pic\" data-state=\"\">
					<div></div>
				</div>
				<div class=\"time-bar\"></div>
				<div class=\"keyframes\"></div>
			</div>
			<style>#{ style }</style>"

		return app

	##
	# 時間区切りの設置
	# @param time: 時間
	##
	setBlock: (time) ->
		@width                 = time * 60
		@time_bar.style.width  = @width + 'px'
		@keyframes.style.width = @width + 'px'

		for i in [0..time - 1]
			sec   = @createTime i
			t_str = sec + ':00'

			@time_bar.innerHTML += "
				<div class=\"block\">#{ t_str }</div>"

	##
	# 時間の生成
	# @param time: 時間
	##
	createTime: (time) ->
		if time < 10
			time = '0' + time
		else
			time = '' + time

		return time

	##
	# タイムライン本体の移動
	# @param pos: 位置
	##
	move: (pos) ->
		@timeline.style.left = pos + 'px'

	##
	# ピックの移動
	# @param time: 時間
	##
	movePic: (time) ->
		@checkActive() 
		@seek_pic.style.left = time + 'px'

	##
	# イベントの紐付け
	##
	bindEvent: ->
		@eventTime()      # 時間の変更（ドラッグ）
		@eventTimeClick() # 時間の変更（クリック）
		@eventPoint()     # ポイントの移動

	##
	# 時間の変更（ドラッグ）のイベント
	##
	eventTime: ->
		down = false
		pic  = @timeline.children[0]

		# mousedown --------------------------------------
		pic.addEventListener 'mousedown', (e) =>
			down = true

		# mousemove --------------------------------------
		window.addEventListener 'mousemove', (e) =>
			if not down
				return

			left = @timeline.getBoundingClientRect().left
			time = e.clientX - left

			if time < 0 # 有効エリアに丸める
				time = 0
			else if time > @width
				time = @width

			app_state.setState 'current_time', time

		# mouseup ----------------------------------------
		window.addEventListener 'mouseup', (e) =>
			down = false

	##
	# 時間の変更イベント（クリック）のイベント
	##
	eventTimeClick: ->
		@time_bar.addEventListener 'click', (e) =>
			left = @time_bar.getBoundingClientRect().left
			time = e.clientX - left

			app_state.setState 'current_time', time

	##
	# ポイントの移動
	##
	eventPoint: ->
		# mousemove -----------------------------------------------
		window.addEventListener 'mousemove', (e) =>
			if not @point_down
				return

			duration  = @time * 60
			left      = @keyframes.getBoundingClientRect().left
			time      = e.clientX - left
			_time     = parseInt(@point_down.style.left) + 5
			parameter = app_state.current_parameter
			keyframes = app_state.current_keyframes
			num       = @getNumber _time

			if time < 0 # 有効エリアに丸める
				time = 0
			else if time > duration
				time = duration

			app_json.keyframes[keyframes][parameter][num].time = time
			@point_down.style.left = (time - 5) + 'px'

			points = app_json.keyframes[keyframes][parameter]
			app_json.keyframes[keyframes][parameter] = @sort points

		# mouseup -------------------------------------------------
		window.addEventListener 'mouseup', (e) =>
			if @point_down isnt false
				UI.history.pushHistory() # 履歴の更新
			@point_down = false

	##
	# 時間順にソート
	# @param points: ポイントの集合
	##
	sort: (points) ->
		_points = copy points

		return _points.sort (a, b) =>
			if a.time > b.time 
				return 1
			else 
				return -1

	##
	# ポイントの番号を取得
	# @param time: 時間
	##
	getNumber: (time) ->
		parameter = app_state.current_parameter
		keyframes = app_state.current_keyframes
		points    = app_json.keyframes[keyframes][parameter]

		for point, i in points
			if point.time is time
				return i

		return false

	##
	# ピックがアクティブか
	##
	checkActive: ->
		time1     = app_state.current_time
		keyframes = app_state.current_keyframes
		parameter = app_state.current_parameter

		if keyframes is false # アニメーション選択されているか
			return false

		points = app_json.keyframes[keyframes][parameter]
		@seek_pic.setAttribute 'data-state', ''

		# 総当たりチェック
		for point in points
			time2 = point.time
			if time1 is time2
				@seek_pic.setAttribute 'data-state', 'active'
				return true

		return false

	##
	# キーフレームの消去
	##
	remove: ->
		@keyframes.innerHTML = ''

	##
	# ポイントの消去
	# @param time: 時間
	##
	removePoint: (time) ->
		time1     = parseInt(time)
		keyframes = app_state.current_keyframes
		parameter = app_state.current_parameter
		points    = app_json.keyframes[keyframes][parameter]
		points2   = @keyframes.children

		for point in points # app.json
			time2 = point.time
			if time1 is time2
				app_json.keyframes[keyframes][parameter].splice i, 1

		for point in points2 # ポイント要素
			time2 = parseInt(point.style.left) + 5
			if time1 is time2
				@keyframes.removeChild point

	##
	# 全ポイントの消去
	##
	removePoints: ->
		points = @keyframes.children

		for point in points
			if point.className is 'point'
				@keyframes.removeChild point

	##
	# 全ポイントの再配置
	##
	reload: ->
		@remove()   # 消去
		@setLabel() # ラベルの設置

		keyframes = app_state.current_keyframes
		parameter = app_state.current_parameter

		if keyframes is false # アニメーション選択されているか
			return

		points = app_json.keyframes[keyframes][parameter]
		for point, i in points
			@setPoint { # ポイントの生成
				num:  i
				time: point.time
			}

	##
	# ポイントの設置
	##
	setPoint: (params) ->
		point = document.createElement 'div'
		point.className  = 'point'
		point.style.left = (params.time - 5) + 'px'

		# mousedown ----------------------------------
		point.addEventListener 'mousedown', (e) =>
			@point_down = e.target

		# contextmenu --------------------------------
		point.addEventListener 'contextmenu', (e) =>
			time = parseInt(e.target.style.left) + 5

			UI.context_menu.render()
			UI.context_menu.setMenu [
				{
					text: '消去'
					callback: () =>
						@removePoint time
						UI.history.pushHistory()
						UI.view.render()
				}
			], e.clientX, e.clientY

		@keyframes.appendChild point

	##
	# ラベルの設置
	##
	setLabel: ->
		keyframes = app_state.current_keyframes
		parameter = app_state.current_parameter
		label     = document.createElement 'div'

		if keyframes is false # アニメーション選択されているか
			return

		label.className = 'label'
		label.innerHTML = keyframes + '<span>&gt;&gt;</span>' + parameter
		@keyframes.appendChild label

module.exports = TimelineUI
	
