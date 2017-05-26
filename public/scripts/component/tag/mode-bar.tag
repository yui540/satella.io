mode-bar(
	style="width:{ width }px"
)

	style(scoped).
		:scope {
			position: absolute;
			bottom: 5px;
			left: 5px;
			height: 35px;
			display: block;
		}

	script(type="coffee").

		# mount ---------------------------------------------
		@on 'mount', ->
			@width = parseInt opts.width - 551
			@update()

		# resize --------------------------------------------
		observer.on 'resize', (params) =>
			@width = parseInt params.width - 551
			@update()