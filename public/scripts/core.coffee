top.Satella  = require '../util/satella'
top.View     = require '../util/view'
top.Sektch   = require '../util/sketch'
top.riot     = require 'riot'
top.observer = riot.observable()

require '../component/js/application'
require '../component/js/title-bar'
require '../component/js/editor'
require '../component/js/workspace'
require '../component/js/status-bar'
require '../component/js/tool-bar'
require '../component/js/tool-icon'
require '../component/js/scroll-bar-side'
require '../component/js/scroll-bar-ver'
require '../component/js/mode-bar'
require '../component/js/project-area'
require '../component/js/animation-area'
require '../component/js/parameter-area'
require '../component/js/parameter-list'
require '../component/js/timeline'
require '../component/js/tabs'
require '../component/js/layer-box'
require '../component/js/layer'
require '../component/js/window-area'
require '../component/js/texture-window'
require '../component/js/trim'

# load -------------------------------------------------
window.addEventListener 'load', ->
	size = getSize()
	riot.mount 'application', size

# resize -----------------------------------------------
window.addEventListener 'resize', ->
	size = getSize()
	observer.trigger 'resize', size

# canvas mount -----------------------------------------
observer.on 'canvas-mount', (params) ->
	mount()

# canvas resize ----------------------------------------
observer.on 'resize', (params) ->
	resize()

# layer sort -------------------------------------------
observer.on 'layer-sort', ->
	satella.render()

##
# マウント
##
top.mount = ->
	# satella
	params                   = getSatellaParams()
	params['canvas']         = document.getElementById 'satella'
	top.satella              = new Satella params
	satella.webgl.style.left = params.x + 'px'
	satella.webgl.style.top  = params.y + 'px'

	# view
	params           = getViewParams()
	params['canvas'] = document.getElementById 'view'
	top.view         = new View params

	# sketch
	top.sketch = new Sektch 
		canvas : document.getElementById 'sketch'
		width  : params.webgl_width
		height : params.webgl_height
	sketch.canvas.style.left = params.x + 'px'
	sketch.canvas.style.top  = params.y + 'px'

	# canvas
	canvas              = document.querySelector '.canvas'
	canvas.style.width  = params.width  + 'px'
	canvas.style.height = params.height + 'px'

	observer.trigger 'satella-ready'

##
# リサイズ
## 
resize = ->
	# satella
	params = getSatellaParams()
	satella.resize params.width, params.height
	satella.webgl.style.left = params.x + 'px'
	satella.webgl.style.top  = params.y + 'px'

	# view
	params = getViewParams()
	view.resize params

	# sketch
	sketch.resize params.webgl_width, params.webgl_height
	sketch.canvas.style.left = params.x + 'px'
	sketch.canvas.style.top  = params.y + 'px'

	# canvas
	canvas              = document.querySelector '.canvas'
	canvas.style.width  = params.width  + 'px'
	canvas.style.height = params.height + 'px'

##
# objectのコピー
# @param  obj : Object
# @return _obj
##
top.copy = (obj) ->
	return JSON.parse JSON.stringify obj

##
# 画面サイズの取得
# @return size
##
top.getSize = ->
	width  = window.innerWidth
	height = window.innerHeight
	width  = if(width >= 1100) then width  else 1100
	height = if(height >= 650) then height else 650
	size   = { width: width, height: height }

	return size

##
# Satellaのパラメータ取得
# @return params
##
top.getSatellaParams = ->
	width   = window.innerWidth
	height  = window.innerHeight
	width   = if(width >= 1100) then width  else 1100
	height  = if(height >= 650) then height else 650
	width   = width  - 571
	height  = height - 207
	_width  = _height = 0
	s       = 20

	if width < height
		_width  = width - s
		_height = width - s
	else
		_width  = height - s
		_height = height - s

	x      = (width - _width) / 2
	y      = (height - _height) / 2
	params = { width: _width, height: _height, x: x, y: y }
	return params

##
# Viewのパラメータ取得
# @return params
##
top.getViewParams = ->
	width   = window.innerWidth
	height  = window.innerHeight
	width   = if(width >= 1100) then width  else 1100
	height  = if(height >= 650) then height else 650
	width   = width  - 571
	height  = height - 207
	_params = getSatellaParams()

	params = 
		width        : width
		height       : height
		x            : _params.x
		y            : _params.y
		webgl_width  : _params.width
		webgl_height : _params.height
	return params


