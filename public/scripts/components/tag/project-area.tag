project-area(style="height:{ _height }px")
	tabs(tab="{ tab }", width="249")
	div.box(style="height:{ box_height }px")
		div.inner(style="height:{ box_height - 10 }px")
			project-box
			layer-box

	style(scoped).
		:scope {
			position: absolute;
			top: 0px;
			left: 0px;
			display: block;
			width: 249px;
			background-color: #333;
		}
		:scope .box {
			width: 249px;
			padding: 5px;
			box-sizing: border-box;
		}
		:scope .box .inner {
			position: relative;
			width: 239px;
			overflow: auto;
		}

	script(type="coffee").

		# mount ---------------------------------------------
		@on 'mount', ->
			@width      = parseInt opts.width
			@height     = parseInt opts.height
			@_height    = (@height - 112) / 2
			@box_height = @_height - 30
			@tab        = JSON.stringify([
				{ title: "プロジェクト", event: "show-project", state: "active" }
				{ title: "レイヤー",    event: "show-layer",   state: "passive" }
			])
			@update()

		# resize --------------------------------------------
		observer.on 'resize', (params) =>
			@width      = params.width
			@height     = params.height
			@_height    = (@height - 112) / 2
			@box_height = @_height - 30
			@update()

