tabs
	div.tab(
		each="{ tab }"
		onclick="{ clickTab }"
		data-event="{ event }"
		data-state="{ state }"
	) 
		p { title }

	style(scoped).
		:scope {
			position: relative;
			width: 249px;
			height: 30px;
			display: block;
			background-color: #4c4c4c;
		}
		:scope:after {
			content: "";
			display: block;
			clear: both;
		}
		:scope .tab {
			position: absolute;
			width: 102.5px;
			border-bottom: solid 30px #3f3f3f;
			border-left: solid 15px transparent;
			border-right: solid 15px transparent;
			font-size: 10px;
			line-height: 30px;
			text-align: center;
			color: #ccc;
			cursor: pointer;
		}
		:scope .tab:first-child { left: 0; }
		:scope .tab:last-child  { left: 116px; }
		:scope .tab[data-state="active"] {
			border-bottom: solid 30px #333;
			z-index: 1;
		}
		:scope .tab p {
			position: absolute;
			top: 0; left: 0;
			width: 100%;
			font-size: 10px;
			line-height: 30px;
			text-align: center;
			color: #ccc;
		}
		:scope .tab[data-state="active"] p {
			color: #595DEF;
		}

	script(type="coffee").

		# mount ---------------------------------------------
		@on 'mount', ->
			@tab    = JSON.parse opts.tab
			@update()
			
		# click tab -----------------------------------------
		self = @
		@clickTab = (e) ->
			for child in self.root.children
				child.setAttribute 'data-state', ''
			@root.setAttribute 'data-state', 'active'

			# イベント発火
			event = @root.getAttribute 'data-event'
			observer.trigger event

