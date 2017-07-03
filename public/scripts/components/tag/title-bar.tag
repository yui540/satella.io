title-bar
	a.logo(href="/")
	div.search-box
		input(type="text", placeholder="Search satella.io", class="search-keyword", size="20")
		input(type="button", value="", class="search-btn")

	div.user-box
		div.user-icon

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
		:scope .search-box {
			float: left;
			width: 300px;
			height: 30px;
			background-color: rgba(255,255,255,0.1);
			margin-top: 5px;
			margin-left: 30px;
			border-radius: 3px;
			overflow: hidden;
		}
		:scope .search-box:after {
			content: ""; display: block; clear: both;
		}
		:scope .search-box .search-keyword {
			float: left;
			display: block;
			width: 250px;
			height: 30px;
			font-size: 12px;
			color: #ccc;
			background-color: transparent;
			box-sizing: border-box;
			padding: 0 10px;
		}
		:scope .search-box .search-keyword::-webkit-input-placeholder { color: #888; }
		:scope .search-box .search-keyword:-moz-placeholder           { color: #888; }
		:scope .search-box .search-keyword::-moz-placeholder          { color: #888; }
		:scope .search-box .search-keyword:focus                      { outline: none; }
		:scope .search-box .search-btn {
			float: left;
			display: block;
			width: 50px;
			height: 30px;
			background-color: transparent;
			box-sizing: border-box;
			background-image: url(/images/title-bar/search.png);
			background-size: auto 70%;
			background-position: center;
			background-repeat: no-repeat;
			cursor: pointer;
		}
		:scope .search-box .search-btn:focus { outline: none; }

	script(type="coffee").

