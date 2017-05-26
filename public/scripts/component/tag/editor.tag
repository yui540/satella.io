editor(style="width:{ width }px;height:{ _height }px")
	project-area(width="{ width }", height="{ height }")
	animation-area(width="{ width }", height="{ height }")
	parameter-area(width="{ width }", height="{ height }")
	parameter-list(width="{ width }", height="{ height }")
	workspace(width="{ width }", height="{ _height }")
	tool-bar(height="{ _height }")
	timeline(width="{ width }", height="{ _height }")

	style(scoped).
		:scope {
			position: absolute;
			top: 41px;
			left: 0;
			display: block;
			overflow: hidden;
			animation: show-editor 1s ease 0s forwards;
		}
		@keyframes show-editor {
			0%   { transform: scale(0.9);opacity: 0; }
			100% { transform: scale(1.0);opacity: 1; }
		}

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