tool-bar(style="height:{ height }px")
	tool-icon(
		iname="texture"
		icon="/images/tool-icon/texture.png"
		licon="/images/tool-icon/texture_l.png"
	)

	style(scoped).
		:scope {
			position: absolute;
			top: 0px;
			right: 0px;
			display: block;
			background-color: #eee;
			width: 40px;
		}

	script(type="coffee").

		# mount ---------------------------------------------
		@on 'mount', ->
			@height = parseInt opts.height - 71
			@update()

		# resize --------------------------------------------
		observer.on 'resize', (params) =>
			@height = params.height - 112
			@update()