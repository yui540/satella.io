tool-icon(onclick="{ onClick }")
	div.bg
	div.icon(style="background-image:url({ icon })")

	style(scoped).
		:scope {
			position: relative;
			width: 40px;
			height: 40px;
			display; block;
			cursor: pointer;
		}
		:scope .bg {
			position: absolute;
			top: 0;
			left: 40px;
			width: 40px;
			height: 40px;
			background-color: #c85399;
		}
		:scope[data-state="active"] .bg  { animation: active 0.2s ease 0s forwards; }
		:scope[data-state="passive"] .bg { animation: passive 0.2s ease 0s forwards; }
		:scope .icon {
			position: absolute;
			top: 0;
			left: 0;
			width: 40px;
			height: 40px;
			background-size: 60%;
			background-position: center;
			background-repeat: no-repeat;
		}
		@keyframes active {
			0%   { left: 40px; }
			100% { left: 0px; }
		}
		@keyframes passive {
			0%   { left: 0px; }
			100% { left: 40px; }
		}

	script(type="coffee").

		##
		# アクティブ
		##
		@active = ->
			@root.setAttribute 'data-state', 'active'
			@root.children[1].style.backgroundImage = 'url(' + @licon + ')'

		##
		# パッシブ
		##
		@passive = ->
			@root.setAttribute 'data-state', 'passive'
			@root.children[1].style.backgroundImage = 'url(' + @icon + ')'

		# click ---------------------------------------------
		@onClick = (e) ->
			state = @root.getAttribute 'data-state'

			if state is 'active'
				@passive()
				observer.trigger 'tool-icon-close', { name: @iname } 
			else
				@active()
				observer.trigger 'tool-icon-close', { name: @iname } 

		# mount ---------------------------------------------
		@on 'mount', ->
			@iname = opts.iname
			@icon  = opts.icon
			@licon = opts.licon
			@update()



