editor(
	style="width:{ width }px;height:{ height }px"
)
	workspace(
		width="{ width }"
		height="{ height }"
	)
	tool-bar(
		height="{ height }"
	)

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
			@width  = parseInt opts.width
			@height = parseInt opts.height - 41
			@update()

		# resize --------------------------------------------
		observer.on 'resize', (params) =>
			@width  = params.width
			@height = params.height - 41
			@update()