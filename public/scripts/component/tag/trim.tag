trim(style="width:{ size }px;height:{ size }px")
	div.rect(
		style="width:{ rect }px;height:{ rect }px;left:{ x }px;top:{ y }px"
	)
		div.point(onmousedown="{ pointDown }")
	
	style(scoped).
		:scope {
			display: block;
			background-color: #4F5B66;
		}
		:scope .rect {
			position: absolute;
			border: solid 1px #BF616A;
			box-sizing: border-box;
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
		# 差分抽出
		# @param  a: 値1
		# @param  b: 値2
		# @return diff
		##
		@diff = (a, b) ->
			if a > b
				return a - b
			else
				return -(b - a)

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
			point_down = { x: e.clientX, y: e.clientY }

		# point move ---------------------------------------
		window.addEventListener 'mousemove', (e) =>
			if not point_down then return

			rect = @root.getBoundingClientRect()
			x    = e.clientX - rect.left
			y    = e.clientY - rect.top
			if Math.abs(x) > Math.abs(y) then @rect -= x
			else                              @rect -= y

			@update()
			point_down = { x: e.clientX, y: e.clientY }

		# point up -----------------------------------------
		window.addEventListener 'mouseup', (e) =>
			point_down = false



