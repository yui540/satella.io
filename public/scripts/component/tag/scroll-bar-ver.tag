scroll-bar-ver(
	style="height:{ height }px"
)
	div.bar(
		style="height:{ _height }px"
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
			left: 1px;
			width: 13px;
			background-color: #000;
			cursor: pointer;
			border-radius: 10px;
		}

	script(type="coffee").

		# mount ---------------------------------------------
		@on 'mount', ->
			@per     = parseFloat opts.per
			@height  = parseInt opts.height - 166
			@_height = @height * @per
			@update()