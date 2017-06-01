workspace(style="width:{ _width }px; height:{ _height }px")
	status-bar
	div.canvas
		canvas#sketch
		canvas#satella
		canvas#view
	scroll-bar-side(width="{ width }", per="0.5")
	scroll-bar-ver(height="{ height }", per="0.5")
	mode-bar(width="{ width }")

	style(scoped).
		:scope {
			position: absolute;
			top: 0;
			right: 41px;
			display: block;
			background-color: #222;
		}
		:scope .canvas {
			position: absolute;
			top: 30px;
			left: 5px;
			background-color: #555;
		}
		:scope #satella {
			position: absolute;
		}
		:scope #view {
			position: absolute;
			top: 0;
			left: 0;
		}
		:scope #sketch {
			position: absolute;
			background-color: #fff;
		}
		:scope scroll-bar-side {
			position: absolute;
			bottom: 45px;
			left: 5px;
		}
		:scope scroll-bar-ver {
			position: absolute;
			top: 30px;
			right: 5px;
		}

	script(type="coffee").

		# mount ---------------------------------------------
		@on 'mount', ->
			@width   = parseInt opts.width
			@height  = parseInt opts.height
			@_width  = @width  - 541
			@_height = @height - 112
			@update()

			# イベント発火
			observer.trigger 'canvas-mount', { width: @width, height: @height }

		# resize --------------------------------------------
		observer.on 'resize', (params) =>
			@width   = parseInt opts.width
			@height  = parseInt opts.height
			@_width  = @width  - 541
			@_height = @height - 112
			@update()
