window-area
	textarea-window(width="{ width }", height="{ height }")

	style(scoped).
		:scope {
			display: block;
		}

	script(type="coffee").

		# mount ---------------------------------------------
		@on 'mount', ->
			@width  = parseInt opts.width
			@height = parseInt opts.height
			@update()