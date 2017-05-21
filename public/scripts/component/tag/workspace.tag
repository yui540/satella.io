workspace(
	style="width:{ width }px;height:{ height }px"
)
	canvas#satella(
		style="left:{ x }px;top:{ y }px"
	)
	canvas#view

	style(scoped).
		:scope {
			position: absolute;
			top: 41px;
			right: 41px;
			display: block;
			background-color: #333;
		}
		:scope #satella {
			position: absolute;
			background-color: #fff;
		}
		:scope #view {
			position: absolute;
			top: 30px;
			left: 5px;
		}

	script(type="coffee").

		##
		# viewサイズ
		# @param  width  : 幅
		# @param  height : 高さ
		# @return size
		##
		@getViewSize = (width, height) ->
			_width  = width  - 30
			_height = height - 90
			size    = { width: _width, height: _height }

			return size

		##
		# Satellaサイズ
		# @param  width  : 幅
		# @param  height : 高さ
		# @return size
		##
		@getSatellaSize = (width, height) ->
			_width  = 0
			_height = 0
			x       = 0
			y       = 0

			if width > height
				_width  = height
				_height = height
				x       = (width - height) / 2
			else
				_width  = width
				_height = width
				y       = (height - width) / 2

			size = { width: _width, height: _height, x: x, y: y }
			return size

		# mount ---------------------------------------------
		@on 'mount', ->
			@width    = parseInt opts.width  - 541
			@height   = parseInt opts.height - 112 

			v_size = @getViewSize @width, @height
			s_size = @getSatellaSize v_size.width, v_size.height
			@x     = s_size.x + 5
			@y     = s_size.y + 30

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

			satella.addLayer
				name    : 'fsfs'
				path    : 'http://localhost:8080/img/texture_00.png'
				quality : 'LINEAR_MIPMAP_LINEAR'
				mesh    : 8
				pos     : { x: 0, y: 0 }
				size    : 1

			view.on 'vertex-move', (data) =>
				satella.moveVertex(0, data.num, data.pos)
				satella.render()

			@update()

		# resize --------------------------------------------
		observer.on 'resize', (params) =>
			@width    = parseInt opts.width  - 541
			@height   = parseInt opts.height - 112 

			v_size = @getViewSize @width, @height
			s_size = @getSatellaSize v_size.width, v_size.height
			@x     = s_size.x + 5
			@y     = s_size.y + 30

			satella.resize s_size.width, s_size.height
			view.resize 
				x            : s_size.x
				y            : s_size.y
				width        : v_size.width
				height       : v_size.height
				webgl_width  : s_size.width
				webgl_height : s_size.height

			@update()



