top.Satella  = require '../utils/js/satella'
top.View     = require '../utils/js/view'
top.Sektch   = require '../utils/js/sketch'
top.riot     = require 'riot'
top.route    = require 'riot-route'
top.observer = riot.observable()

require '../components/js/login'
require '../components/js/top'
require '../components/js/dashboard'
require '../components/js/create'
require '../components/js/user'
require '../components/js/view'
require '../components/js/search'
require '../components/js/title-bar'
require '../components/js/editor'
require '../components/js/workspace'
require '../components/js/status-bar'
require '../components/js/tool-bar'
require '../components/js/tool-icon'
require '../components/js/scroll-bar-side'
require '../components/js/scroll-bar-ver'
require '../components/js/mode-bar'
require '../components/js/project-area'
require '../components/js/animation-area'
require '../components/js/parameter-area'
require '../components/js/parameter-list'
require '../components/js/timeline'
require '../components/js/tabs'
require '../components/js/project-box'
require '../components/js/layer-box'
require '../components/js/layer'
require '../components/js/animation-box'
require '../components/js/keyframes-box'
require '../components/js/parameter-box'
require '../components/js/register-layer-box'
require '../components/js/window-area'
require '../components/js/texture-window'
require '../components/js/trim'

########################################################
# Routing                                              #
########################################################
page = null
route.start true
route.base '/'

# / ----------------------------------------------------
route '/', ->
	mountPage 'top'

# /login -----------------------------------------------
route '/login', ->
	mountPage 'login'

# /dashboard -------------------------------------------
route '/dashboard', ->
	mountPage 'dashboard'
	
# /create ----------------------------------------------
route '/create', ->
	mountPage 'create'

# /editor ----------------------------------------------
route '/editor', ->
	mountPage 'editor'

# /users/:name -----------------------------------------
route '/users/*', (name) ->
	mountPage 'user'

# /search ----------------------------------------------
route '/search..', ->
	q = route.query().q
	mountPage 'search'

##
# ページのマウント
##
mountPage = (component) ->
	console.log 'change_page -> ' + component
	if page isnt null
		page[0].unmount true

	size = getSize()
	page = riot.mount component, size

########################################################
# Event                                                #
########################################################

# load -------------------------------------------------
window.addEventListener 'load', ->
	size = getSize()
	riot.mount 'title-bar'

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
	width  = window.innerWidth
	height = window.innerHeight
	width  = if(width >= 1100) then width  else 1100
	height = if(height >= 650) then height else 650
	width  = width  - 571
	height = height - 207
	_width = _height = 0
	s      = 20

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


