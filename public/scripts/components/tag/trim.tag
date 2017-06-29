trim(style="width:{ size }px;height:{ size }px")
	div.rect(
		onmousedown="{ rectDown }"
		style="width:{ rect }px;height:{ rect }px;left:{ x }px;top:{ y }px"
	)
		div.point(onmousedown="{ pointDown }")
	
	style(scoped).
		:scope {
			display: block;
			background-color: #4F5B66;
			background-image: url(/img/texture_00.png);
			background-size: contain;
			background-repeat: no-repeat;
			background-position: center;
		}
		:scope .rect {
			position: absolute;
			border: solid 1px #BF616A;
			box-sizing: border-box;
			box-shadow: 0 0 10px #222;
		}
		:scope .rect .point {
			position: absolute;
			bottom: 0; right: 0;
			width: 10px;
			height: 10px;
			background-color: #BF616A;
		}

	script(type="coffee").

		##
		# 差分の算出
		# @param a : 値1
		# @param b : 値2
		##
		@diff = (a, b) ->
			if a > b then return a - b
			else          return -(b - a)

		##
		# 切り取り範囲の設定
		# @param size : 大きさ
		##
		@setSize = (size) ->
			if size < 30 then size = 30
			@rect = size
			@update()

			observer.trigger ''

		##
		# 切り取り位置の設定
		# @param x : x座標
		# @param y : y座標
		##
		@setPos = (x, y) ->
			_x = x + @rect
			_y = y + @rect

			if      _x > @size then x = (_x - (_x - @size)) - @rect
			else if x < 0      then x = 0

			if      _y > @size then y = (_y - (_y - @size)) - @rect
			else if y < 0      then y = 0

			@x = x
			@y = y
			@update()

		# mount ---------------------------------------------
		@on 'mount', ->
			@size = parseInt opts.size
			@rect = @size
			@x    = 0
			@y    = 0
			@update()

		# point down ---------------------------------------
		point_down = false
		@pointDown = (e) ->
			e.stopPropagation()
			point_down = true

		# point move ---------------------------------------
		window.addEventListener 'mousemove', (e) =>
			if not point_down then return

			rect = @root.getBoundingClientRect()
			x    = e.clientX - rect.left
			y    = e.clientY - rect.top
			if      x > @size then return
			else if y > @size then return

			x    = @diff x, @x
			y    = @diff y, @y
			if Math.abs(x) > Math.abs(y)
				@setSize x
			else @setSize y

		# point up -----------------------------------------
		window.addEventListener 'mouseup', (e) =>
			point_down = false

		# rect down ----------------------------------------
		rect_down = false
		@rectDown = (e) ->
			rect      = e.target.getBoundingClientRect()
			rect_down = 
				x: e.clientX - rect.left
				y: e.clientY - rect.top

		# rect move ----------------------------------------
		window.addEventListener 'mousemove', (e) =>
			if not rect_down then return

			rect = @root.getBoundingClientRect()
			x    = e.clientX - rect.left - rect_down.x
			y    = e.clientY - rect.top  - rect_down.y

			@setPos x, y

		# rect up ------------------------------------------
		window.addEventListener 'mouseup', (e) =>
			rect_down = false



