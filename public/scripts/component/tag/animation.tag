animation(style="height:{ _height }px")
	

	style(scoped).
		:scope {
			position: absolute;
			bottom: 71px;
			left: 0px;
			display: block;
			width: 249px;
			background-color: #333;
		}

	script(type="coffee").

		# mount ---------------------------------------------
		@on 'mount', ->
			@width   = parseInt opts.width
			@height  = parseInt opts.height
			@_height = ((@height - 112) / 2) - 1
			@update()

		# resize --------------------------------------------
		observer.on 'resize', (params) =>
			@width   = params.width
			@height  = params.height
			@_height = ((@height - 112) / 2) - 1
			@update()