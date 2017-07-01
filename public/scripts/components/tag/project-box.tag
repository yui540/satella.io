project-box

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
		
		# mount -------------------------------------------
		@on 'mount', ->
				
			@update()

		# show project ------------------------------------
		observer.on 'show-project', =>
			@active()

		# show layer --------------------------------------
		observer.on 'show-layer', =>
			@passive()
