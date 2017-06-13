textarea-window(
	style="top:{ y }px;left:{ x }px"
)
	div.title-bar(onmousedown="{ mouseDown }")
		div.close(onclick="{ clickClose }")
	div.body
		trim(size="250")

	style(scoped).
		:scope {
			position: fixed;
			width: 500px; height: 400px;
			background-color: #313743;
			border-radius: 5px;
			box-shadow: 0 0 10px #000;
			display: none;
		}
		:scope[data-state="active"]  { animation: open-texture-window 0.3s ease 0s forwards; }
		:scope[data-state="passive"] { animation: close-texture-window 0.3s ease 0s forwards; }
		:scope[data-show="open"]  { display: block; }
		:scope[data-show="close"] { display: none; }
		:scope .title-bar {
			position: absolute;
			top: 0;
			width: 100%;
			height: 30px;
			border-bottom: solid 1px #BF616A;
		}
		:scope .title-bar .close {
			position: absolute;
			top: 0;
			width: 30px;
			height: 30px;
		}
		:scope .title-bar .close:before,
		:scope .title-bar .close:after {
			content: "";
			display: block;
			position: absolute;
			top: 14.5px;
			left: 5px;
			width: 20px;
			height: 1px;
			background-color: #BF616A;
		}
		:scope .title-bar .close:before { transform: rotate(45deg); }
		:scope .title-bar .close:after  { transform: rotate(-45deg); }
		:scope .body {
			position: absolute;
			top: 31px;
			width: 500px; height: 369px;
		}
		@keyframes open-texture-window {
			0%   { opacity: 0; transform: scale(0.9); }
			100% { opacity: 1; transform: scale(1.0); }
		}
		@keyframes close-texture-window {
			0%   { opacity: 1; transform: scale(1.0); }
			100% { opacity: 0; transform: scale(0.9); }
		}

	script(type="coffee").

		##
		# ウィンドウを開く
		##
		@openWindow = ->
			@root.setAttribute 'data-state', 'active'
			@root.setAttribute 'data-show', 'open'

		##
		# ウィンドウを閉じる
		##
		@closeWindow = ->
			@root.setAttribute 'data-state', 'passive'
			setTimeout =>
				@root.setAttribute 'data-show', 'close'
			, 300

		##
		# ウィンドウ移動
		# @param x: x座標
		# @param y: y座標
		##
		@move = (x, y) ->
			@x = x
			@y = y
			@update()

		# mount ---------------------------------------------
		@on 'mount', ->
			@width  = parseInt opts.width
			@height = parseInt opts.height
			@iname  = 'texture'
			@size   = { w: 500, h: 400 }
			@x      = (@width / 2) - (@size.w / 2)
			@y      = (@height / 2) - (@size.h / 2)
			@update()

		# open ---------------------------------------------
		observer.on 'tool-icon-open', (iname) =>
			if @iname is iname
				@openWindow()

		# close --------------------------------------------
		observer.on 'tool-icon-close', (iname) =>
			if @iname is iname
				@closeWindow()

		# click close --------------------------------------
		@clickClose = (e) ->
			observer.trigger 'tool-icon-close', @iname

		# mouse down ---------------------------------------
		bar_down = false
		@mouseDown = (e) ->
			x        = e.pageX - @x
			y        = e.pageY - @y - 50
			bar_down = { x: x, y: y }

		# mouse move ---------------------------------------
		window.addEventListener 'mousemove', (e) =>
			if bar_down is false then return

			max_x = @width - @size.w - 40
			max_y = @height - @size.h - 40
			x     = e.pageX - bar_down.x
			y     = e.pageY - bar_down.y - 50

			if x < 0          then x = 0
			else if x > max_x then x = max_x
			if y < 0          then y = 0
			else if y > max_y then y = max_y

			@move x, y

		# mouse up -----------------------------------------
		window.addEventListener 'mouseup', (e) =>
			bar_down = false
			

		

