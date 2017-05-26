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
			color: #999;
			background-color: #444;
			border-bottom: solid 1px #444;
			cursor: pointer;
		}
		:scope .tab[data-state="active"] {
			animation: show-tab 0.3s ease 0s forwards;
		}
		:scope .tab[data-state="passive"] {
			animation: hidden-tab 0.3s ease 0s forwards;
		}
		@keyframes show-tab {
			0% { 
				color: #999;
				background-color: #444;
				border-bottom: solid 1px #444;
			}
			100% {
				color: #c85399;
				border-bottom: solid 1px #c85399;
				background-color: #222;
			}
		}
		@keyframes hidden-tab {
			0% {
				color: #c85399;
				border-bottom: solid 1px #c85399;
				background-color: #222;
			}
			100% { 
				color: #999;
				background-color: #444;
				border-bottom: solid 1px #444;
			}
		}

	script(type="coffee").

		# click tab -----------------------------------------
		@clickTab = (e) =>
			for child in @root.children
				child.setAttribute 'data-state', 'passive'
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