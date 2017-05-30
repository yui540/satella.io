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
				layer.push
					name  : l.name
					thumb : l.path
					look  : l.look

			return layer

		# mount ---------------------------------------------
		@on 'mount', ->
			@layer  = []
			@height = @layer.length * 41
			@update()
