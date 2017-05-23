scroll-bar-side(
	style="width:{ width }px"
)
	div.bar(
		style="width:{ _width }px"
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
			top: 1px;
			height: 13px;
			background-color: #000;
			cursor: pointer;
			border-radius: 10px;
		}

	script(type="coffee").

		# mount ---------------------------------------------
		@on 'mount', ->
			@per    = parseFloat opts.per
			@width  = parseInt opts.width - 571
			@_width = @width * @per
			@update()

		# resize --------------------------------------------
		observer.on 'resize', (params) =>
			@per    = parseFloat opts.per
			@width  = parseInt params.width - 571
			@_width = @width * @per
			@update()