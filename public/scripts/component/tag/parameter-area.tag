parameter-area(style="height:{ _height }px")
	tabs(tab="{ tab }", width="249")
	div.box(style="height:{ b_height }px")

	style(scoped).
		:scope {
			position: absolute;
			bottom: 71px;
			left: 250px;
			display: block;
			width: 249px;
			background-color: #222;
		}

	script(type="coffee"). 

		# mount ---------------------------------------------
		@on 'mount', ->
			@width    = parseInt opts.width
			@height   = parseInt opts.height
			@_height  = ((@height - 112) / 2) - 1
			@b_height = @_height - 30
			@tab      = JSON.stringify([
				{ title: "パラメータ", event: "show-parameter", state: "active" }
				{ title: "登録レイヤー", event: "show-register-layer", state: "passive" }
			])
			@update()

		# resize --------------------------------------------
		observer.on 'resize', (params) =>
			@width   = params.width
			@height  = params.height
			@_height = ((@height - 112) / 2) - 1
			@b_height = @_height - 30
			@update()