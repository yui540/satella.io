search-page(

	data-state="active"
	style="width:{ width }px;height:{ _height }px"
)
	

	style(scoped).
		:scope {
			position: relative;
			top: 41px;
			left: 0;
			display: block;
			overflow: hidden;
			z-index: 1;
		}
		:scope[data-state="active"] { animation: active-page 0.5s ease 0s forwards; }
	
	script(type="coffee").
		
		# mount -----------------------------------------------
		@on 'mount', ->
			@width   = parseInt opts.width
			@height  = parseInt opts.height
			@_height = @height - 41
			@update()

		# resize ----------------------------------------------
		observer.on 'resize', (params) =>
			@width   = params.width
			@height  = params.height
			@_height = @height - 41
			@update()
