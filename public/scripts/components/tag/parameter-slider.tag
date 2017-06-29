parameter-slider(data-num="{ num }", data-type="{ type }", data-id="{ id }")
	div.type2
		div.left
			div.name { name }
			div.icon
		div.right
			div.slider
				div.bar
				div.picker(onmousedown="{ pickerType2 }")
	div.type4
		div.left
			div.name { name }
			div.icon
		div.right
			div.slider
				div.picker(onmousedown="{ pickerType4 }")

	style(scoped).
		:scope {
			width: 239px;
			display: block;
			margin-bottom: 5px;
		}
		:scope[data-num="2"] .type2 { display: block; }
		:scope[data-num="4"] .type4 { display: block; }
		:scope[data-type="rotate"] .icon { background-image: url(/images/parameter/rotate.png); }
		:scope[data-type="move"]   .icon { background-image: url(/images/parameter/move.png);   }
		:scope .type2 {
			width: 239px; 
			height: 40px;
			background-color: #333;
			border-radius: 3px;
			overflow: hidden;
			display: none;
		}
		:scope .type2:after {
			content: "";
			display: block;
			clear: both;
		}
		:scope .type2 .left {
			float: left;
			width: 59px;
			height: 40px;
			margin-right: 5px;
		}
		:scope .type2 .left .name {
			width: 49px;
			height: 20px;
			font-size: 10px;
			color: #ccc;
			text-align: center;
			line-height: 20px;
			margin-left: 5px;
			overflow: hidden;
			box-sizing: border-box;
		}
		:scope .type2 .left .icon {
			width: 59px;
			height: 20px;
			background-size: auto 70%;
			background-repeat: no-repeat;
			background-position: center;
			background-color: #444;
		}
		:scope .type2 .right {
			float: left;
			width: 170px;
			height: 40px;
		}
		:scope .type2 .right .slider {
			position: relative;
			width: 170px;
			height: 5px;
			background-color: #4c4c4c;
			margin-top: 17px;
		}
		:scope .type2 .right .slider .bar {
			position: absolute;
			top: 0; left: 0;
			height: 5px;
			background-color: #595DEF;
		}
		:scope .type2 .right .slider .picker {
			position: absolute;
			top: -5px;
			width: 15px;
			height: 15px;
			border-radius: 50%;
			background-color: #ccc;
			cursor: pointer;
		}
		:scope .type4 {
			width: 239px;
			height: 80px;
			background-color: #333;
			border-radius: 3px;
			overflow: hidden;
			display: none;
		}
		:scope .type4:after {
			content: "";
			display: block;
			clear: both;
		}
		:scope .type4 .left {
			float: left;
			width: 59px;
			height: 40px;
			margin-right: 5px;
		}
		:scope .type4 .left .name {
			width: 49px;
			height: 20px;
			font-size: 10px;
			color: #ccc;
			text-align: center;
			line-height: 20px;
			margin-left: 5px;
			overflow: hidden;
			box-sizing: border-box;
		}
		:scope .type4 .left .icon {
			width: 59px;
			height: 20px;
			margin-top: 40px;
			background-size: auto 70%;
			background-repeat: no-repeat;
			background-position: center;
			background-color: #444;
		}
		:scope .type4 .right {
			float: left;
			width: 170px;
			height: 80px;
		}
		:scope .type4 .right .slider {
			position: relative;
			width: 170px;
			height: 70px;
			margin-top: 5px;
			background-color: #4c4c4c;
		}
		:scope .type4 .right .slider:before {
			position: absolute;
			top: 34.5px;
			content: "";
			display: block;
			width: 100%;
			height: 1px;
			background-color: #595DEF;
		}
		:scope .type4 .right .slider:after {
			position: absolute;
			left: 84.5px;
			content: "";
			display: block;
			width: 1px;
			height: 100%;
			background-color: #595DEF;
		}
		:scope .type4 .right .slider .picker {
			position: absolute;
			width: 15px;
			height: 15px;
			border-radius: 50%;
			background-color: #ccc;
			cursor: pointer;
			z-index: 1;
		}

	script(type="coffee").

		#####################################################
		#
		# type2
		#
		#####################################################

		##
		# typeのピッカー移動
		# @param per : 割合
		##
		@moveType2Picker = (per) ->
			x   = 155 * per
			bar = @root.children[0].children[1].children[0].children[0]
			pic = @root.children[0].children[1].children[0].children[1]
			pic.style.left  = x + 'px'
			bar.style.width = 100 * per + '%'
			return true

		# type2 down ----------------------------------------
		type2_down = false
		@pickerType2 = (e) ->
			type2_down = true

		# type2 move ----------------------------------------
		window.addEventListener 'mousemove', (e) =>
			if not type2_down
				return 

			left = @root.children[0].children[1].children[0].getBoundingClientRect().left
			x    = e.clientX - left - 7.5
			
			if x > 155
				x = 155
			else if x < 0
				x = 0

			per = x / 155
			@moveType2Picker per

		# type2 up ------------------------------------------
		window.addEventListener 'mouseup', (e) =>
			type2_down = false

		#####################################################
		#
		# type4
		#
		#####################################################

		##
		# typeのピッカー移動
		# @param per_x : 割合
		# @param per_y : 割合
		##
		@moveType4Picker = (per_x, per_y) ->
			x   = 155 * per_x
			y   = 55  * per_y
			pic = @root.children[1].children[1].children[0].children[0]
			pic.style.left = x + 'px'
			pic.style.top  = y + 'px'
			return true

		# type2 down ----------------------------------------
		type4_down = false
		@pickerType4 = (e) ->
			type4_down = true

		# type4 move ----------------------------------------
		window.addEventListener 'mousemove', (e) =>
			if not type4_down
				return 

			rect = @root.children[1].children[1].children[0].getBoundingClientRect()
			x    = e.clientX - rect.left - 7.5
			y    = e.clientY - rect.top - 7.5
			
			if x > 155
				x = 155
			else if x < 0
				x = 0

			if y > 55
				y = 55
			else if y < 0
				y = 0

			per_x = x / 155
			per_y = y / 55
			@moveType4Picker per_x, per_y

		# type4 up ------------------------------------------
		window.addEventListener 'mouseup', (e) =>
			type4_down = false


		# mount ---------------------------------------------
		@on 'mount', ->
			@id   = parseInt opts.id
			@num  = parseInt opts.num
			@type = opts.type
			@name = opts.name

			x    = parseFloat opts.x
			y    = parseFloat opts.y
			if @num is 2
				@moveType2Picker x
			else
				@moveType4Picker x, y

			@update()

