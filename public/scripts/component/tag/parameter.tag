parameter(style="height:{ _height }px")
	div.tabs
		div.tab(onclick="{ clickTab }", data-state="active") パラメータ
		div.tab(onclick="{ clickTab }") 登録レイヤー
	div.box(style="height:{ b_height }px")

	style(scoped).
		:scope {
			position: absolute;
			bottom: 71px;
			left: 250px;
			display: block;
			width: 249px;
			background-color: #333;
		}
		:scope .tabs {
			width: 249px;
			height: 30px;
		}
		:scope .tabs:after {
			content: "";
			display: block;
			clear: both;
		}
		:scope .tabs .tab {
			float: left;
			width: 124px;
			height: 30px;
			box-sizing: border-box;
			font-size: 10px;
			line-height: 30px;
			text-align: center;
			color: #999;
			background-color: #555;
			border-bottom: solid 1px #555;
			cursor: pointer;
		}
		:scope .tabs .tab[data-state="active"] {
			color: #c85399;
			border-bottom: solid 1px #c85399;
			background-color: #333;
		}
		:scope .box {
			width: 249px;
		}

	script(type="coffee"). 

		# mount ---------------------------------------------
		@on 'mount', ->
			@width    = parseInt opts.width
			@height   = parseInt opts.height
			@_height  = ((@height - 112) / 2) - 1
			@b_height = @_height - 30
			@update()

		# resize --------------------------------------------
		observer.on 'resize', (params) =>
			@width   = params.width
			@height  = params.height
			@_height = ((@height - 112) / 2) - 1
			@b_height = @_height - 30
			@update()