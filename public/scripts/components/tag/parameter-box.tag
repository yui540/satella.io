parameter-box
	
	style(scoped).
		:scope {
			display: block;
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

		# show parameter ------------------------------------
		observer.on 'show-parameter', =>
			@active()

		# show register layer -------------------------------
		observer.on 'show-register-layer', =>
			@passive()
