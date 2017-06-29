status-bar
	span.status-li mouse_x:
		span.status-val { mouse_x }
	span.status-li mouse_y:
		span.status-val { mouse_y }
	span.status-li scale:
		span.status-val { scale }
	span.status-li camera_x:
		span.status-val { camera_x }
	span.status-li camera_y:
		span.status-val { camera_y }
	span.status-li mode:
		span.status-val { mode }

	style(scoped).
		:scope {
			position: absolute;
			top: 0;
			left: 0;
			width: 100%;
			height: 30px;
			display: block;
		}	
		:scope .status-li {
			font-size: 10px;
			color: #ccc;
			height: 30px;
			line-height: 30px;
			margin-left: 10px;
		}
		:scope .status-val {
			color: #E27171;
			margin-left: 5px;
		}

	script(type="coffee").

		##
		# マウス位置
		# @param x : x座標
		# @param y : y座標
		## 
		@setMouse = (x, y) ->
			@mouse_x = x.toFixed 2
			@mouse_y = y.toFixed 2
			@update()
			return true

		##
		# マウス位置
		# @param scale : 割合
		## 
		@setScale = (scale) ->
			@mouse_x = scale.toFixed 2
			@update()
			return true

		##
		# カメラ位置
		# @param x : x座標
		## 
		@setCameraX = (x) ->
			@camera_x = x.toFixed 2
			@update()
			return true

		##
		# カメラ位置
		# @param y : y座標
		## 
		@setCameraY = (y) ->
			@camera_y = y.toFixed 2
			@update()
			return true

		##
		# 編集モード
		# @param mode : モード
		## 
		@setMouse = (mode) ->
			@mode = mode
			@update()
			return true

		# mount ---------------------------------------------
		@on 'mount', ->
			@mouse_x  = 0.toFixed 2
			@mouse_y  = 0.toFixed 2
			@scale    = 1.toFixed 2
			@camera_x = 0.5.toFixed 2
			@camera_y = 0.5.toFixed 2
			@mode     = 'polygon'
			@update()
			
		# status mouse ---------------------------------------
		observer.on 'status-mouse', (data) =>
			@setMouse data.x, data.y

		# status scale ---------------------------------------
		observer.on 'status-scale', (data) =>
			@setScale data.scale

		# status camera x ------------------------------------
		observer.on 'status-camera-x', (data) =>
			@setCameraX data

		# status camera y ------------------------------------
		observer.on 'status-camera-y', (data) =>
			@setCameraY data

		# status mode ----------------------------------------
		observer.on 'status-mode', (data) =>
			@setMode data.mode


