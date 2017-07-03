title-bar
	a.logo(href="/")
	search-box
	user-box(user_name="yuki540", user_icon="/img/yuki540.png")

	style(scoped).
		:scope {
			display: block;
			position: absolute;
			top: 0;
			left: 0;
			width: 100%;
			height: 40px;
			background-color: #222;
			z-index: 5;
		}
		:scope:after {
			content: ""; display: block; clear: both;
		}
		:scope .logo {
			float: left;
			width: 30px;
			height: 30px;
			background-image: url(/images/icons/logo.png);
			background-size: 100%;
			margin-top: 5px;
			margin-left: 30px;
			display: block;
		}
		:scope search-box { float: left; }
		:scope user-box   { float: right; }

	script(type="coffee").
		
		# mount ------------------------------------------------------
		@on 'mount', ->
			@user_icon = '/img/yuki540.png'
			@user_name = 'yuki540'
			@update()
