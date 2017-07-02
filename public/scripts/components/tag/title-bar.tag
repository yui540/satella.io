title-bar
	div.logo

	style(scoped).
		:scope {
			display: block;
			position: absolute;
			top: 0;
			left: 0;
			width: 100%;
			height: 40px;
			background-color: #222;
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
			margin-left: 10px;
		}

	script(type="coffee").

