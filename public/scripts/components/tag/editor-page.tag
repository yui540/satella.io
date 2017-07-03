editor-page(
	data-state="active" 
	style="width:{ width }px;height:{ _height }px"
)
	project-area(width="{ width }", height="{ height }")
	animation-area(width="{ width }", height="{ height }")
	parameter-area(width="{ width }", height="{ height }")
	parameter-list(width="{ width }", height="{ height }")
	workspace(width="{ width }", height="{ height }")
	tool-bar(height="{ height }")
	timeline(width="{ width }", height="{ height }")
	window-area(width="{ width }", height="{ height }")

	style(scoped).
		:scope {
			position: absolute;
			top: 41px;
			left: 0;
			display: block;
			overflow: hidden;
			z-index: 1;
		}
		:scope[data-state="active"] { animation: active-page 0.5s ease 0s forwards; }
	
	script(type="coffee").

		# mount ---------------------------------------------
		@on 'mount', ->
			@width   = parseInt opts.width
			@height  = parseInt opts.height
			@_height = @height - 41
			@update()

		# resize --------------------------------------------
		observer.on 'resize', (params) =>
			@width   = params.width
			@height  = params.height
			@_height = @height - 41
			@update()
