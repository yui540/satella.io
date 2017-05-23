editor(style="width:{ width }px;height:{ _height }px")
	project(width="{ width }", height="{ height }")
	animation(width="{ width }", height="{ height }")
	parameter(width="{ width }", height="{ height }")
	parameter-list(width="{ width }", height="{ height }")
	workspace(width="{ width }", height="{ _height }")
	tool-bar(height="{ _height }")
	timeline(width="{ width }", height="{ _height }")

	style(scoped).
		:scope {
			position: absolute;
			top: 41px;
			left: 0;
			display: block;
			overflow: hidden;
		}

	script(type="coffee").

		# mount ---------------------------------------------
		@on 'mount', ->
			@width   = parseInt opts.width
			@height  = parseInt opts.height
			@_height = @height - 41
			@update()

		# resize --------------------------------------------
		observer.on 'resize', (params) =>
			@width   = params.width
			@height  = params.height
			@_height = @height - 41
			@update()