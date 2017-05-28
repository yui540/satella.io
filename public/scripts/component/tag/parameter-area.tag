parameter-area(style="height:{ _height }px")
	tabs(tab="{ tab }", width="249")
	div.box(style="height:{ b_height }px")
		div.inner(style="height:{ b_height - 10 }px")
			parameter-slider(
				id="{ i }"
				each="{ val, i in slider }"
				type="{ val.type }"
				num="{ val.num }"
				name="{ val.name }"
				x="{ val.x }"
				y="{ val.y }"
			)

	style(scoped).
		:scope {
			position: absolute;
			bottom: 71px;
			left: 250px;
			display: block;
			width: 249px;
			background-color: #222;
		}
		:scope .box {
			width: 249px;
		}
		:scope .box .inner {
			width: 239px;
			margin: 5px;
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
				{ title: "パラメータ",   event: "show-parameter", state: "active" }
				{ title: "登録レイヤー", event: "show-register-layer", state: "passive" }
			])
			@slider   = [
				{ name: "fsfs", type: "rotate", num: 2, x: 0.5  }
				{ name: "fsfs", type: "move", num: 4, x: 0.5, y: 0.5 }
			]
			@update()

		# resize --------------------------------------------
		observer.on 'resize', (params) =>
			@width   = params.width
			@height  = params.height
			@_height = ((@height - 112) / 2) - 1
			@b_height = @_height - 30
			@update()