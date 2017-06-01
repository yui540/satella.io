class Sketch
	constructor: (params) ->
		# canvas
		@canvas = params.canvas

		# context
		@ctx = @canvas.getContext "2d"

		# size 
		@width  = params.width
		@height = params.height
		@resize @width, @height

	##
	# リサイズ
	# @param width  : 幅
	# @param hegiht : 高さ
	##
	resize: (width, height) ->
		@width         = width
		@height        = height
		@canvas.width  = @width
		@canvas.height = @height

		return true	
	
try 
	module.exports = Sketch
catch