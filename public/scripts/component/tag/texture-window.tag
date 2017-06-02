textarea-window
	div.title-bar
		div.close(onclick="{ closeWindow }")
	div.body

	style(scoped).
		:scope {
			position: fixed;
			top: 50px;
			left: 50px;
			width: 500px; height: 400px;
			background-color: #313743;
			border-radius: 5px;
			box-shadow: 0 0 20px #000;
			display: block;
		}
		:scope .title-bar {
			position: absolute;
			top: 0;
			width: 100%;
			height: 30px;
			border-bottom: solid 1px #BF616A;
		}
		:scope .title-bar .close {
			position: absolute;
			top: 0;
			width: 30px;
			height: 30px;
		}
		:scope .title-bar .close:before,
		:scope .title-bar .close:after {
			content: "";
			display: block;
			position: absolute;
			top: 14.5px;
			left: 5px;
			width: 20px;
			height: 1px;
			background-color: #BF616A;
		}
		:scope .title-bar .close:before { transform: rotate(45deg); }
		:scope .title-bar .close:after  { transform: rotate(-45deg); }
		:scope .body {
			position: absolute;
			top: 31px;
			width: 500px; height: 369px;
		}

	script(type="coffee").

		# mount ---------------------------------------------
		@on 'mount', ->


		# close window --------------------------------------
		@closeWindow = (e) ->
