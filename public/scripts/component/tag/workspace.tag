workspace(
	style="width:{ _width }px;height:{ _height }px"
)
	status-bar
	div.canvas(
		style="width:{ c_width }px;height:{ c_height }px"
	)
		canvas#satella(
			style="left:{ x }px;top:{ y }px"
		)
		canvas#view
	scroll-bar-ver(
		iname="camera-move-y"
		height="{ height }"
		per="0.5"
	)
	scroll-bar-side(
		iname="camera-move-x"
		width="{ width }"
		per="0.5"
	)
	mode-bar(
		width="{ width }"
	)

	style(scoped).
		:scope {
			position: absolute;
			top: 0;
			right: 41px;
			display: block;
			background-color: #333;
			animation: show 0.5s ease 0s forwards;
			transform: scale(0.9);
			-webkit-user-select: none;
		}
		:scope .canvas {
			position: absolute;
			top: 30px;
			left: 5px;
			background-color: #555;
		}
		:scope #satella {
			position: absolute;
			background-color: #fff;
		}
		:scope #view {
			position: absolute;
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
		@keyframes show {
			0%   { transform: scale(0.9); }
			100% { transform: scale(1.0); }
		}

	script(type="coffee").

		##
		# viewサイズ
		# @param  width  : 幅
		# @param  height : 高さ
		# @return size
		##
		@getViewSize = (width, height) ->
			_width  = width  - 30 - 541
			_height = height - 95 - 71
			size    = { width: _width, height: _height }

			return size

		##
		# Satellaサイズ
		# @param  width  : 幅
		# @param  height : 高さ
		# @return size
		##
		@getSatellaSize = (width, height) ->
			_width  = 0; _height = 0
			x       = 0; y       = 0

			if width > height
				_width  = height; _height = height
				x       = (width - height) / 2
			else
				_width  = width;  _height = width
				y       = (height - width) / 2

			size = { width: _width, height: _height, x: x, y: y }
			return size

		# mount ---------------------------------------------
		@on 'mount', ->
			@width    = parseInt opts.width
			@height   = parseInt opts.height
			@_width   = @width  - 541
			@_height  = @height - 71
			v_size    = @getViewSize @width, @height
			s_size    = @getSatellaSize v_size.width, v_size.height
			@c_width  = v_size.width
			@c_height = v_size.height
			@x        = s_size.x
			@y        = s_size.y

			top.view = new View 
				canvas       : document.getElementById 'view'
				width        : v_size.width
				height       : v_size.height
				webgl_width  : s_size.width
				webgl_height : s_size.height
				x            : s_size.x
				y            : s_size.y

			top.satella = new Satella
				canvas : document.getElementById 'satella'
				width  : s_size.width
				height : s_size.height

			for i in [0..0]
				satella.addLayer
					name    : 'fsfs' + i
					path    : '/img/texture_0' + i + '.png'
					quality : 'LINEAR_MIPMAP_LINEAR'
					mesh    : 15
					pos     : { x: 0, y: 0 }
					size    : 1

			view.on 'vertex-move', (data) =>
				satella.moveVertex 0, data.num, data.pos
				satella.render()

			@update()

		# resize --------------------------------------------
		observer.on 'resize', (params) =>
			@width    = parseInt opts.width
			@height   = parseInt opts.height
			@_width   = @width  - 541
			@_height  = @height - 71
			v_size    = @getViewSize @width, @height
			s_size    = @getSatellaSize v_size.width, v_size.height
			@c_width  = v_size.width
			@c_height = v_size.height
			@x        = s_size.x
			@y        = s_size.y

			satella.resize s_size.width, s_size.height
			view.resize 
				x            : s_size.x
				y            : s_size.y
				width        : v_size.width
				height       : v_size.height
				webgl_width  : s_size.width
				webgl_height : s_size.height

			@update()
