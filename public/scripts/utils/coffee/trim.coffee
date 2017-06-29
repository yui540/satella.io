class Trim
	constructor: (canvas) ->
		@canvas = canvas
		@ctx    = @canvas.getContext '2d'

	##
	# 最も近い値を取得
	##
	getSize: (size) ->
		_size = [2, 4, 8, 32, 64, 128, 256, 512, 1024]
		
	
