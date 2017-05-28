layer
	div.show(data-state="{ show }")
	div.thumb(style="background-image:url({ thumb })")
	div.name { name }

	style(scoped).
		:scope {
			display: block;
			width: 239px;
			height: 40px;
			border-bottom: solid 1px #4c4c4c;
		}
		:scope:after {
			content: "";
			display: block;
			clear: both;
		}
		:scope .show[data-state="true"] { 
			background-position: center;
			background-size: 80%;
			background-repeat: no-repeat;
			background-image:url(/images/project/check.png); 
		}
		:scope .show {
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

		# mount ---------------------------------------------
		@on 'mount', ->
			@name  = opts.name
			@thumb = opts.thumb
			@show  = opts.show
			@update()