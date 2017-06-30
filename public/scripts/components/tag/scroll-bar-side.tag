scroll-bar-side(
	style="width:{ _width }px"
)
	div.bar(
		style="width:{ bar_width }px;left:{ x }px"
		onmousedown="{ mouseDown }"
	)

	style(scoped).
		:scope {
			position: relative;
			display: block;
			background-color: #555;
			height: 15px;
		}
		:scope .bar {
			position: absolute;
			top: 2px;
			left: 2px;
			height: 11px;
			background-color: #333;
			cursor: pointer;
			border-radius: 10px;
		}

	script(type="coffee").

		##
		# シーク移動
		# @param pos : 割合
		##
		@seek = (pos) ->
			@pos = pos
			diff = (@_width - 4) - @bar_width
			@x   = diff * @pos + 2
			return true

		# mount ---------------------------------------------
		@on 'mount', ->
			@pos       = 0.5
			@per       = parseFloat opts.per
			@width     = parseInt opts.width
			@_width    = @width - 571
			@bar_width = (@_width - 4) * @per
			@seek @pos
			@update()

		# resize --------------------------------------------
		observer.on 'resize', (params) =>
			@width     = parseInt params.width
			@_width    = @width - 571
			@bar_width = (@_width - 4) * @per
			@seek @pos
			@update()

		# mouse down ----------------------------------------
		down = false
		@mouseDown = (e) ->
			left = e.target.getBoundingClientRect().left
			down = e.clientX - left

		# mouse move ----------------------------------------
		window.addEventListener 'mousemove', (e) =>
			if down is false then return

			left = @root.getBoundingClientRect().left
			pos  = e.clientX - left - down
			diff = (@_width - 4) - @bar_width

			if pos < 2               then pos = 2
			else if pos > (diff + 2) then pos = diff + 2
			pos = (pos - 2) / diff
			observer.trigger 'status-camera-x', pos
			@seek pos
			@update()

		# mouse up ------------------------------------------
		window.addEventListener 'mouseup', (e) =>
			down = false


