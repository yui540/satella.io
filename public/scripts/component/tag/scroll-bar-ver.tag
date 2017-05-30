scroll-bar-ver(
	style="height:{ _height }px"
)
	div.bar(
		style="height:{ bar_height }px"
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
			top: 2px;
			left: 2px;
			width: 11px;
			background-color: #000;
			cursor: pointer;
			border-radius: 10px;
		}

	script(type="coffee").

		# mount ---------------------------------------------
		@on 'mount', ->
			@per        = parseFloat opts.per
			@height     = parseInt opts.height
			@_height    = @height - 207
			@bar_height = @_height * @per
			@update()

		# resize --------------------------------------------
		observer.on 'resize', (params) =>
			@height     = params.height
			@_height    = @height - 207
			@bar_height = @_height * @per
			@update()



