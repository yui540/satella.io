editor(data-state="active" style="width:{ width }px;height:{ _height }px")
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
		}
		:scope[data-state="active"]  { animation: show-editor 1s ease 0s forwards; }
		:scope[data-state="passive"] { animation: hidden-editor 1s ease 0s forwards; }
		@keyframes show-editor {
			0%   { transform: scale(0.9);opacity: 0; }
			100% { transform: scale(1.0);opacity: 1; }
		}
		@keyframes hidden-editor {
			0%   { transform: scale(1.0);opacity: 1; }
			100% { transform: scale(0.9);opacity: 0; }
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