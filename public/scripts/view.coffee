class View
	constructor: (params) ->
		# canvas
		@canvas = params.canvas
		@ctx    = @canvas.getContext '2d'
		
		# rect
		@x            = params.x
		@y            = params.y
		@width        = params.width
		@height       = params.height
		@webgl_width  = params.webgl_width
		@webgl_height = params.webgl_height
		@resize 
			width        : @width
			height       : @height,
			webgl_width  : @webgl_width
			webgl_height : @webgl_height
			x            : @x, 
			y            : @y

		# listeners
		@listeners = []

		# position
		@position = []

		# イベント紐付け
		@bindEvent()

	##
	# イベントリスナの追加
	# @param event : イベント名
	# @param fn    : コールバック関数
	##
	on: (event, fn) ->
		@listeners.push 
			event : event
			fn    : fn

		return true

	##
	# イベントの発火
	# @param event : イベント名
	# @param data  : データ
	##
	emit: (event, data) ->
		for listener in @listeners
			if event is listener.event
				listener.fn data

		return true

	##
	# サイズの変更
	# @param params : 
	##
	resize: (params) ->
		@x             = params.x
		@y             = params.y
		@width         = params.width
		@height        = params.height
		@webgl_width   = params.webgl_width
		@webgl_height  = params.webgl_height
		@canvas.width  = @width
		@canvas.height = @height

		return true

	##
	# 範囲内かチェック
	# @param _x : 対象のx座標
	# @param _y : 対象のy座標
	# @param x  : x座標
	# @param y  : y座標
	##
	checkVertex: (_x, _y, x, y) ->
		r = 5
		if ((_x - 5) <= x) and ((_x + 5) >= x) and ((_y - 5) <= y) and ((_y + 5) >= y)
			return true
		else
			return false

	##
	# イベントの紐付け
	##
	bindEvent: ->
		@eventVertex()

	##
	# 頂点モードのイベント
	##
	eventVertex: ->
		down = false

		# mouse down -------------------------------------------------
		@canvas.addEventListener 'mousedown', (e) =>
			c    = 0
			rect = @canvas.getBoundingClientRect()
			x    = e.clientX - rect.left
			y    = e.clientY - rect.top

			for i in [0...@position.length] by 3
				_x   = @position[i]
				_y   = @position[i + 1]
				bool = @checkVertex _x, _y, x, y

				if bool
					down = c
					pos  = @decode _x, _y
					@emit 'vertex-down', { num: c, pos: pos }

				c += 1

		# mouse move -------------------------------------------------
		window.addEventListener 'mousemove', (e) =>
			if down is false
				return

			rect = @canvas.getBoundingClientRect()
			x    = e.clientX - rect.left
			y    = e.clientY - rect.top
			pos  = @decode x, y
			@emit 'vertex-move', { num: down, pos: pos }

		# mouse up   -------------------------------------------------
		window.addEventListener 'mouseup', (e) =>
			down = false
			@emit 'vertex-up', {}

	##
	# クリア
	##
	clear: ->
		@ctx.beginPath()
		@ctx.clearRect 0, 0, @width, @height
		@ctx.closePath()

		return true

	##
	# 描画
	# @param position : 座標行列
	# @param mesh     : メッシュ数
	##
	render: (position, mesh) ->
		@position = @encodeAll position
		@clear()

		for y in [0...mesh]
			for x in [0...mesh]
				_x   = (x * 3) + ((mesh + 1) * 3 * y)
				pos1 = @encode position[_x],     position[_x + 1]
				pos2 = @encode position[_x + 3], position[_x + 4]
				pos3 = @encode(
					position[_x + ((mesh + 1) * 3)], 
					position[_x + ((mesh + 1) * 3) + 1]
				)
				@drawLine3 pos1, pos2, pos3

				if (y + 1) is mesh
					_xx = (x * 3) + ((mesh + 1) * 3 * (y + 1))
					p1  = @encode position[_xx],     position[_xx + 1]
					p2  = @encode position[_xx + 3], position[_xx + 4]
					@drawLine2 p1, p2

			p1 = (mesh * 3) + (((mesh + 1) * 3) * y)
			p1 = @encode position[p1], position[p1 + 1]
			p2 = (mesh * 3) + (((mesh + 1) * 3) * (y + 1))
			p2 = @encode position[p2], position[p2 + 1]
			@drawLine2 p1, p2

		for i in [0...position.length] by 3
			pos = @encode position[i], position[i + 1]
			@drawVertex pos.x, pos.y

		return true

	##
	# 実際のサイズの位置情報に変換
	# @param  x : x座標
	# @param  y : y座標
	# @return pos
	##
	encode: (x, y) ->
		x   = (x + 2.5) / 5
		y   = 1 - ((y + 2.5) / 5)
		x   = @webgl_width  * x + @x
		y   = @webgl_height * y + @y
		pos = { x: x, y: y }

		return pos

	##
	# 実際のサイズの位置情報に変換（座標行列）
	# @param  position : 座標行列
	# @return _position
	##
	encodeAll: (position) ->
		_position = []
		for i in [0...position.length] by 3
			p = @encode position[i], position[i + 1]
			_position.push p.x
			_position.push p.y
			_position.push position[i + 2]

		return _position

	##
	# 実際のサイズの位置情報に逆変換
	# @param  x : x座標
	# @param  y : y座標
	# @return pos
	##
	decode: (x, y) ->
		x  -= @x
		y  -= @y
		x   = x / @webgl_width
		y   = y / @webgl_height
		x   = 5 * x
		y   = 5 * y
		x   = x - 2.5
		y   = (y - 2.5) * -1
		pos = { x: x, y: y }

		return pos

	##
	# 実際のサイズの位置情報に逆変換（座標行列）
	# @param  position : 座標行列
	# @return _position
	##
	decodeAll: (position) ->
		_position = []
		for i in [0...position.length] by 3
			p = @decode position[i], position[i + 1]
			_position.push p.x
			_position.push p.y
			_position.push position[i + 2]

		return _position

	##
	# 線画の描画（2点）
	# @param pos1 : 点1
	# @param pos2 : 点2
	##
	drawLine2: (pos1, pos2) ->
		@ctx.save()
		@ctx.beginPath()
		@ctx.strokeStyle = '#ff0000'
		@ctx.lineWidth   = 0.5
		@ctx.setLineDash [3, 3]
		@ctx.moveTo pos1.x, pos1.y
		@ctx.lineTo pos2.x, pos2.y
		@ctx.closePath()
		@ctx.stroke()
		@ctx.restore()

		return true

	##
	# 線画の描画（3点）
	# @param pos1 : 点1
	# @param pos2 : 点2
	# @param pos3 : 点3
	##
	drawLine3: (pos1, pos2, pos3) ->
		@ctx.save()
		@ctx.beginPath()
		@ctx.strokeStyle = '#ff0000'
		@ctx.lineWidth   = 0.5
		@ctx.setLineDash [3, 3]
		@ctx.moveTo pos1.x, pos1.y
		@ctx.lineTo pos2.x, pos2.y
		@ctx.lineTo pos3.x, pos3.y
		@ctx.lineTo pos1.x, pos1.y
		@ctx.closePath()
		@ctx.stroke()
		@ctx.restore()

		return true

	##
	# 頂点の描画
	# @param x : x座標
	# @param y : y座標
	##
	drawVertex: (x, y) ->
		size = 4
		@ctx.save()
		@ctx.beginPath()
		@ctx.fillStyle   = '#fff'
		@ctx.strokeStyle = '#000'
		@ctx.lineWidth   = 1
		@ctx.rect x - size / 2, y - size / 2, size, size
		@ctx.fill()
		@ctx.stroke()
		@ctx.closePath()
		@ctx.restore()

		return true

try
	module.exports = View
catch