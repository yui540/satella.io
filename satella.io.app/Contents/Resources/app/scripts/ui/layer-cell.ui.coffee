class LayerCellUI
	constructor: (params) ->
		@app = params.app

		@select = false
		@state  = params.active # 表示状態
		@num    = params.num    # レイヤー番号
		@pos    = params.pos    # 位置
		@img    = params.img    # 画像
		@name   = params.name   # 名前

	##
	# 描画
	##
	render: ->
		@layer_cell = document.createElement 'section'
		@layer_cell.style.top = "#{ @pos }px"
		@layer_cell.className = 'layer-cell'
		@layer_cell.setAttribute 'data-num', @num
		@layer_cell.setAttribute 'data-layer', @num

		@layer_check_btn = document.createElement 'div'
		@layer_check_btn.className = 'layer-check-btn'
		@layer_check_btn.setAttribute 'data-state', @state

		@layer_thumb = document.createElement 'div'
		@layer_thumb.className = 'layer-thumb'
		@layer_thumb.style.backgroundImage = "url(#{ @img })"

		@layer_name = document.createElement 'div'
		@layer_name.className = 'layer-name'
		@layer_name.innerHTML = "<span></span>#{ @name }"

		@layer_cell.appendChild @layer_check_btn
		@layer_cell.appendChild @layer_thumb
		@layer_cell.appendChild @layer_name
		@app.appendChild @layer_cell

	##
	# 消去
	##
	delete: ->
		@app.removeChild @layer_cell

	##
	# 移動
	# @param pos: 位置
	##
	move: (pos) ->
		@layer_cell.setAttribute 'data-layer', @num
		@layer_cell.style.top = "#{ pos }px"

	##
	# 固定位置移動
	##
	repos: ->
		@layer_cell.setAttribute 'data-layer', @num
		@layer_cell.style.top = "#{ @pos }px"

	##
	# 選択
	# @param bool: 真偽値
	##
	selectCell: (bool) ->
		if bool
			@select = true
			@layer_cell.setAttribute 'data-select', 'true'
		else
			@select = false
			@layer_cell.setAttribute 'data-select', 'false'

	##
	# 状態チェック
	##
	check: ->
		if @state is 'show'
			@state = 'hidden'
			app_json.layer[@num].show = 'hidden'
		else
			@state = 'show'
			app_json.layer[@num].show = 'show'

		@layer_check_btn.setAttribute 'data-state', @state

module.exports = LayerCellUI