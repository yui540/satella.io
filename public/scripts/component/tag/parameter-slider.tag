parameter-slider
	div.type2
		div.left
			div.name fsfsfs
			div.icon
		div.right
			div.slider
				div.bar
				div.picker

	style(scoped).
		:scope {
			width: 239px;
			display: block;
			margin: 5px;
		}
		:scope .type2 {
			width: 239px;
			height: 40px;
			background-color: #333;
			border-radius: 3px;
			overflow: hidden;
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
			background-image: url(/images/parameter/rotate.png);
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
			width: 20%;
			height: 5px;
			background-color: #c85399;
		}
		:scope .type2 .right .slider .picker {
			position: absolute;
			top: -5px;
			left: 20px;
			width: 15px;
			height: 15px;
			border-radius: 50%;
			background-color: #ccc;
			cursor: pointer;
		}

	script(type="coffee").

		# mount ---------------------------------------------
		@on 'mount', ->