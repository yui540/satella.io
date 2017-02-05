class SaveUI
	constructor: (app) ->

	##
	# プロジェクトの状態・情報の保存
	##
	write: ->
		e_json = JSON.stringify(app_json)
		a_json = JSON.stringify {
			directory:         app_state.directory
			current_time:      app_state.current_time
			current_layer:     app_state.current_layer
			current_parameter: app_state.current_parameter
			current_keyframes: app_state.current_keyframes
			play:              app_state.play
			mode:              app_state.mode
			scale:             app_state.scale
			position:          app_state.position
			parameter:         app_state.parameter
			history:           app_state.history
			current_history:   app_state.current_history
		}

		@writeFile app_state.directory + 'app.json', e_json
		@writeFile app_state.directory + 'app-state.json', a_json

	##
	# ファイルの書き出し
	# @param file_path: ファイルパス
	# @param data:      ファイル内容
	##
	writeFile: (file_path, data) ->
		fs = require 'fs'

		try
			fs.writeFileSync file_path, data, 'utf8'
			return true
		catch err
			return false
		

module.exports = SaveUI