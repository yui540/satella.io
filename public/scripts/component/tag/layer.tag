layer(
	style="top:{ i * 41 }px"
	onmousedown="{ layerDown }"
)
	div.look(data-state="{ look }")
	div.thumb(style="background-image:url({ thumb })")
	div.name { name }

	style(scoped).
		:scope {
			position: absolute;
			display: block;
			width: 239px;
			height: 40px;
			border-bottom: solid 1px #4c4c4c;
			background-color: #222;
		}
		:scope:after {
			content: "";
			display: block;
			clear: both;
		}
		:scope .look[data-state="show"] {
			background-position: center;
			background-size: 80%;
			background-repeat: no-repeat;
			background-image:url(/images/project/check.png);
		}
		:scope .look {
			float: left;
			width: 15px;
			height: 15px;
			margin-top: 12.5px;
			margin-left: 10px;
			background-color: #4c4c4c;
			border-radius: 3px;
			cursor: pointer;
		}
		:scope .thumb {
			float: left;
			width: 40px;
			height: 30px;
			margin-top: 5px;
			margin-left: 10px;
			background-position: center;
			background-size: contain;
			background-repeat: no-repeat;
			background-color: #4c4c4c;
		}
		:scope .name {
			float: left;
			width: 154px;
			height: 30px;
			margin-top: 5px;
			margin-left: 10px;
			background-position: center;
			background-size: contain;
			background-repeat: no-repeat;
			background-color: #4c4c4c;
			font-size: 10px;
			line-height: 30px;
			color: #fff;
			padding: 0 5px;
			overflow: hidden;
			box-sizing: border-box;
		}

	script(type="coffee").

		##
		# 差分の取得
		# @param  a : 値1
		# @param  b : 値2
		# @return diff
		##
		@diff = (a, b) ->
			if a > b
				return a - b
			else
				return -(b - a)

		##
		# レイヤーの移動
		# @param y : y座標
		##
		@move = (y) ->
			@root.style.zIndex = 1
			@root.style.top    = y + 'px'
			return true

		##
		# 指定位置に戻る
		##
		@repos = ->
			@root.style.zIndex = 0
			@root.style.top    = @i * 41 + 'px'
			return true

		# mount ---------------------------------------------
		@on 'mount', ->
			@i     = parseInt opts.i
			@name  = opts.name
			@thumb = opts.thumb
			@look  = opts.look
			@update()

		# layer down ----------------------------------------
		down = false
		@layerDown = (e) ->
			top  = @root.getBoundingClientRect().top
			down = e.clientY - top

		# layer move ----------------------------------------
		window.addEventListener 'mousemove', (e) =>
			if not down
				return

			layer_box = document.querySelector('layer-box')
			len       = (layer_box.children.length - 1) * 41
			top       = layer_box.getBoundingClientRect().top
			pos       = @i * 41
			y         = e.clientY - top - down

			if y < 0
				y = 0
			else if y > len
				y = len
			
			# 並べ替え
			diff = @diff y, pos
			if diff >= 20.5
				@i += 1
			else if diff <= -20.5
				@i -= 1

			@move y

		# layer up ------------------------------------------
		window.addEventListener 'mouseup', (e) =>
			@repos()
			down = false