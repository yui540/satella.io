class ThumbUI
	constructor: (params) ->
		@app = params.app
		@size = params.size

	##
	# 描画
	##
	render: ->
		@app.width  = @size
		@app.height = @size
		@ctx = @app.getContext '2d'

	##
	# 保存
	##
	save: (callback) ->
		f_path = app_state.directory + 'thumb.png'
		fs     = require 'fs'
		data   = UI.view.webgl.toDataURL()
		img    = new Image()

		# load -----------------------------
		img.onload = =>
			@ctx.drawImage img, 0, 0, @size, @size

			thumb = @app.toDataURL()
			thumb = thumb.replace(/data:image\/png;base64,/, '')

			fs.writeFileSync f_path, thumb, 'base64'
			callback()
		img.src = data

module.exports = ThumbUI