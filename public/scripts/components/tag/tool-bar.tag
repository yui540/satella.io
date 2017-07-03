tool-bar(style="height:{ height }px")
	div.line
	tool-icon(
		iname="texture"
		icon="/images/editor-page/tool-bar/texture.png"
		licon="/images/editor-page/tool-bar/texture_l.png"
	)
	tool-icon(
		iname="parameter"
		icon="/images/editor-page/tool-bar/param.png"
		licon="/images/editor-page/tool-bar/param_l.png"
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
		:scope .line {
			position: absolute;
			top: 0;
			left: 19.5px;
			width: 1px;
			height: 100%;
			background-color: #ccc;
		}

	script(type="coffee").

		# mount ---------------------------------------------
		@on 'mount', ->
			@height = parseInt opts.height - 112
			@update()

		# resize --------------------------------------------
		observer.on 'resize', (params) =>
			@height = params.height - 112
			@update()
