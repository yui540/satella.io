user-box
	div.pulldown
	div.user-name: div { user_name }
	div.user-icon(style="background-image:url({ user_icon })")

	style(scoped).
		:scope {
			position: relative;
			border-left: solid 1px #4c4c4c;
			width: 192px;
			height: 40px;
			cursor: pointer;
			display: block;
		}
		:scope .pulldown {
			position: absolute;
			top: 10px;
			left: 5px;
			width: 20px;
			height: 20px;
			background-image: url(/images/title-bar/pulldown.png);
			background-size: 60%;
			background-position: center;
			background-repeat: no-repeat;
			opacity: 0.7;
		}
		:scope .user-name {
			position: absolute;
			top: 5px;
			left: 25px;
			width: 127px;
			height: 30px;
			border-right: solid 1px #4c4c4c;
		}
		:scope .user-name div {
			position: absolute;
			top: 0;
			left: 5px;
			width: 117px;
			height: 30px;
			overflow: hidden;
			font-size: 12px;
			color: #ccc;
			text-align: right;
			line-height: 30px;
		}
		:scope .user-icon {
			position: absolute;
			right: 5px;
			top: 5px;
			width: 30px;
			height: 30px;
			border-radius: 50%;
			background-size: cover;
			background-position: center;
		}

	script(type="coffee").
	
		# mount --------------------------------------------------
		@on 'mount', ->
			@user_name = opts.user_name
			@user_icon = opts.user_icon
			@update()
