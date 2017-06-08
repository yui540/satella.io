tool-icon(onclick="{ onClick }")
	div.bg
	div.icon(style="background-image:url({ icon })")

	style(scoped).
		:scope {
			position: relative;
			width: 35px;
			height: 35px;
			display: block;
			cursor: pointer;
			margin-left: 2.5px;
			margin-top: 10px;
			border-radius: 50%;
			background-color: #ccc;
			overflow: hidden;
			z-index: 3;
		}
		:scope .bg {
			position: absolute;
			top: 0;
			left: 0;
			width: 35px;
			height: 35px;
			background-color: #c85399;
			border-radius: 50%;
			transform: scale(0.0);
		}
		:scope[data-state="active"] .bg  { animation: active 0.3s ease 0s forwards; }
		:scope[data-state="passive"] .bg { animation: passive 0.3s ease 0s forwards; }
		:scope .icon {
			position: absolute;
			top: 0;
			left: 0;
			width: 35px;
			height: 35px;
			background-size: 60%;
			background-position: center;
			background-repeat: no-repeat;
		}
		@keyframes active {
			0%   { transform: scale(0.0); }
			100% { transform: scale(1.0); }
		}
		@keyframes passive {
			0%   { transform: scale(1.0); }
			100% { transform: scale(0.0);; }
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



