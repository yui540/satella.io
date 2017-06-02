scroll-bar-side(
	style="width:{ _width }px"
)
	div.bar(
		style="width:{ bar_width }px"
	)

	style(scoped).
		:scope {
			position: relative;
			display: block;
			background-color: #4F5B66;
			height: 15px;
		}
		:scope .bar {
			position: absolute;
			top: 2px;
			left: 2px;
			height: 11px;
			background-color: #2B303B;
			cursor: pointer;
			border-radius: 10px;
		}

	script(type="coffee").

		# mount ---------------------------------------------
		@on 'mount', ->
			@per       = parseFloat opts.per
			@width     = parseInt opts.width
			@_width    = @width - 571
			@bar_width = @_width * @per
			@update()

		# resize --------------------------------------------
		observer.on 'resize', (params) =>
			@width     = parseInt params.width
			@_width    = @width - 571
			@bar_width = @_width * @per
			@update()

