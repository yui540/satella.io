search-box
	input(type="text", placeholder="Search satella.io", class="search-keyword", size="20")
	input(type="button", value="", class="search-btn")

	style(scoped).
		:scope {
			width: 300px;
			height: 30px;
			background-color: rgba(255,255,255,0.1);
			margin-top: 5px;
			margin-left: 30px;
			border-radius: 3px;
			overflow: hidden;
			display: block;
		}
		:scope:after {
			content: ""; display: block; clear: both;
		}
		:scope .search-keyword {
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
		:scope .search-keyword::-webkit-input-placeholder { color: #888; }
		:scope .search-keyword:-moz-placeholder           { color: #888; }
		:scope .search-keyword::-moz-placeholder          { color: #888; }
		:scope .search-keyword:focus                      { outline: none; }
		:scope .search-btn {
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
		:scope .search-btn:focus { outline: none; }

	script(type="coffee").
	
		# mount --------------------------------------------------
		@on 'mount', ->
			@update()
