parameter-area(style="height:{ _height }px")
	tabs(tab="{ tab }")
	div.box(style="height:{ b_height }px")
		div.inner(style="height:{ b_height - 10 }px")
			parameter-box
			register-layer-box

	style(scoped).
		:scope {
			position: absolute;
			bottom: 71px;
			left: 250px;
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
			width: 239px;
			overflow: auto;
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
			@width    = params.width
			@height   = params.height
			@_height  = ((@height - 112) / 2) - 1
			@b_height = @_height - 30
			@update()
