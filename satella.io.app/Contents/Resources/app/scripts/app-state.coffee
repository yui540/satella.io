class AppState
	constructor: (params) ->
		for key, val of params
			this[key] = val

		@listeners = []

	setState: (type, data) ->
		this[type] = data
		
		for i in [0..@listeners.length - 1]
			if @listeners[i] is undefined
				continue

			if @listeners[i].type is type
				@listeners[i].callback()

	bind: (type, callback) -> 
		@listeners.push({
			type:     type
			callback: callback
		})

module.exports = AppState