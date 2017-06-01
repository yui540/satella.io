layer-box(style="height:{ height }px")
	layer(
		each="{ li, i in layer }"
		i="{ i }"
		look="{ li.look }"
		name="{ li.name }"
		thumb="{ li.thumb }"
	)

	style(scoped).
		:scope {
			position: relative;
			display: block;
			width: 239px;
		}

	script(type="coffee").

		##
		# レイヤーの取得
		# @return layer
		##
		@getLayer = ->
			layer  = []
			_layer = copy satella.model.layer
			for l, i in _layer
				layer.unshift
					name  : l.name
					thumb : l.path
					look  : l.look

			return layer

		# mount ---------------------------------------------
		@on 'mount', ->
			@layer  = []
			@height = @layer.length * 41
			@update()

		# satella ready -------------------------------------
		observer.on 'satella-ready', =>
			@bindAdd()

			for i in [0...3]
				satella.addLayer 
					name : "tex" + i
					path : "/img/texture_0" + i + ".png"
					mesh : 10
					size : 1
					pos  : { x: 0, y: 0 }
					quality : 'LINEAR_MIPMAP_LINEAR'

		# satella add ---------------------------------------
		@bindAdd = ->
			satella.on 'add', =>
				@layer = @getLayer()
				@update()

				satella.render()
