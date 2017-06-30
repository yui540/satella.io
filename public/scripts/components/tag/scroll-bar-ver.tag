scroll-bar-ver(
	style="height:{ _height }px"
)
	div.bar(
		style="height:{ bar_height }px;top:{ y }px"
		onmousedown="{ mouseDown }"
	)

	style(scoped).
		:scope {
			position: relative;
			display: block;
			background-color: #555;
			width: 15px;
		}
		:scope .bar {
			position: absolute;
			left: 2px;
			width: 11px;
			background-color: #333;
			cursor: pointer;
			border-radius: 10px;
		}

	script(type="coffee").

		##
		# シークバーの移動
		# @param per : 割合
		##
		@seek = (pos) ->
			@pos = pos
			diff = (@_height - 4) - @bar_height
			@y   = diff * @pos + 2
			return true

		# mount ---------------------------------------------
		@on 'mount', ->
			@pos        = 0.5
			@per        = parseFloat opts.per
			@height     = parseInt opts.height
			@_height    = @height - 207
			@bar_height = (@_height - 4) * @per
			@seek @pos
			@update()

		# resize --------------------------------------------
		observer.on 'resize', (params) =>
			@height     = params.height
			@_height    = @height - 207
			@bar_height = (@_height - 4) * @per
			@seek @pos
			@update()

		# mouse down ----------------------------------------
		down = false
		@mouseDown = (e) ->
			top  = e.target.getBoundingClientRect().top
			down = e.clientY - top

		# mouse move ----------------------------------------
		window.addEventListener 'mousemove', (e) =>
			if down is false then return

			top  = @root.getBoundingClientRect().top
			pos  = e.clientY - top - down
			diff = (@_height - 4) - @bar_height

			if pos < 2               then pos = 2
			else if pos > (diff + 2) then pos = diff + 2
			
			pos = (pos - 2) / diff
			observer.trigger 'status-camera-y', pos
			@seek pos
			@update()

		# mouse up ------------------------------------------
		window.addEventListener 'mouseup', (e) =>
			down = false


