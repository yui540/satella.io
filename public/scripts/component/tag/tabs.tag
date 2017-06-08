tabs(style="width:{ width }px")
	div.tab(
		style="width:{ _width }px"
		each="{ tab }"
		onclick="{ clickTab }"
		data-event="{ event }"
		data-state="{ state }"
	) { title }

	style(scoped).
		:scope {
			height: 30px;
			display: block;
		}
		:scope:after {
			content: "";
			display: block;
			clear: both;
		}
		:scope .tab {
			float: left;
			height: 30px;
			box-sizing: border-box;
			font-size: 10px;
			line-height: 30px;
			text-align: center;
			color: #ccc;
			background-color: #4F5B66;
			border-bottom: solid 1px #4F5B66;
			cursor: pointer;
		}
		:scope .tab[data-state="active"] {
			color: #595DEF;
			border-bottom: solid 1px #595DEF;
			background-color: #313743;
		}

	script(type="coffee").

		# click tab -----------------------------------------
		@clickTab = (e) =>
			for child in @root.children
				child.setAttribute 'data-state', ''
			e.target.setAttribute 'data-state', 'active'

			# イベント発火
			event = e.target.getAttribute 'data-event'
			observer.trigger event

		# mount ---------------------------------------------
		@on 'mount', ->
			@tab    = JSON.parse opts.tab
			@width  = parseInt opts.width
			@_width = @width / @tab.length
			@update()