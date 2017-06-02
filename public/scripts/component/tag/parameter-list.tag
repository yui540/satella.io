parameter-list(style="height:{ _height }px")
	

	style(scoped).
		:scope {
			position: absolute;
			top: 0px;
			left: 250px;
			display: block;
			width: 249px;
			background-color: #313743;
		}

	script(type="coffee").

		# mount ---------------------------------------------
		@on 'mount', ->
			@width   = parseInt opts.width
			@height  = parseInt opts.height
			@_height = ((@height - 112) / 2)
			@update()

		# resize --------------------------------------------
		observer.on 'resize', (params) =>
			@width   = params.width
			@height  = params.height
			@_height = ((@height - 112) / 2)
			@update()