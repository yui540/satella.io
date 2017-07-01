keyframes-box
	
	style(scoped).
		:scope {
			display: none;
		}

	script(type="coffee").

		##
		# 表示
		##
		@active = ->
			@root.style.display = 'block'
			return true

		##
		# 非表示
		##
		@passive = ->
			@root.style.display = 'none'
			return true

		# mount ---------------------------------------------
		@on 'mount', ->
			@update()

		# show animation ------------------------------------
		observer.on 'show-animation', =>
			@passive()

		# show keyframes ------------------------------------
		observer.on 'show-keyframes', =>
			@active()
