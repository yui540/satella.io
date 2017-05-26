project-area(style="height:{ _height }px")
	tabs(tab="{ tab }", width="249")

	style(scoped).
		:scope {
			position: absolute;
			top: 0px;
			left: 0px;
			display: block;
			width: 249px;
			background-color: #222;
		}

	script(type="coffee").

		# mount ---------------------------------------------
		@on 'mount', ->
			@width   = parseInt opts.width
			@height  = parseInt opts.height
			@_height = ((@height - 112) / 2)
			@tab     = JSON.stringify([
				{ title: "プロジェクト", event: "show-project", state: "active" }
				{ title: "レイヤー", event: "show-layer", state: "passive" }
			])
			@update()

		# resize --------------------------------------------
		observer.on 'resize', (params) =>
			@width   = params.width
			@height  = params.height
			@_height = ((@height - 112) / 2)
			@update()