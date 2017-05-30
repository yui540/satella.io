top.Satella  = require '../util/satella'
top.View     = require '../util/view'
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
require '../component/js/parameter-slider'

# load -------------------------------------------------
window.addEventListener 'load', ->
	size = getSize()
	riot.mount 'application', size

# resize -----------------------------------------------
window.addEventListener 'resize', ->
	size = getSize()
	observer.trigger 'resize', size

# satella mount ----------------------------------------
observer.on 'satella-mount', (params) ->
	mountSattela params

# satella resize ---------------------------------------
observer.on 'resize', (params) ->
	resizeSatella params

##
# Satellaのマウント
# @param params : { width, height }
##
top.mountSattela = (params) ->
	width   = params.width  - 571
	height  = params.height - 207
	_width  = 0
	_height = 0
	s       = 20

	if width < height
		_width  = width - s
		_height = width - s
	else
		_width  = height - s
		_height = height - s

	top.satella = new Satella
		canvas : document.getElementById 'satella'
		width  : _width
		height : _height

	satella.addLayer 
		name    : "fsfs"
		path    : "/img/texture_00.png"
		mesh    : 10
		quality : "LINEAR_MIPMAP_LINEAR"
		pos     : { x: 0, y: 0 }
		size    : 1

	satella.on 'add', ->
		satella.render()

	mountView 
		width        : width
		height       : height
		webgl_width  : _width
		webgl_height : _height

##
# Viewのマウント
# @param params : { width, height, webgl_width, webgl_height } 
##
mountView = (params) ->
	canvas              = document.querySelector('.canvas')
	canvas.style.width  = params.width  + 'px'
	canvas.style.height = params.height + 'px'
	x                   = (params.width - params.webgl_width)   / 2
	y                   = (params.height - params.webgl_height) / 2
	webgl               = document.getElementById 'satella'
	webgl.style.left    = x + 'px'
	webgl.style.top     = y + 'px'

	top.view = new View
		canvas       : document.getElementById 'view'
		width        : params.width
		height       : params.height
		x            : x
		y            : y
		webgl_width  : params.webgl_width
		webgl_height : params.webgl_height

##
# Satellaのリサイズ
# @param params : { width, height }
##
top.resizeSatella = (params) ->
	width   = params.width  - 571
	height  = params.height - 207
	_width  = 0
	_height = 0
	s       = 20

	if width < height
		_width  = width - s
		_height = width - s
	else
		_width  = height - s
		_height = height - s

	satella.resize _width, _height
	resizeView 
		width        : width
		height       : height
		webgl_width  : _width
		webgl_height : _height

##
# Viewのリサイズ
# @param params : { width, height, webgl_width, webgl_height }
##
top.resizeView = (params) ->
	canvas              = document.querySelector('.canvas')
	canvas.style.width  = params.width  + 'px'
	canvas.style.height = params.height + 'px'
	x                   = (params.width - params.webgl_width)   / 2
	y                   = (params.height - params.webgl_height) / 2
	webgl               = document.getElementById 'satella'
	webgl.style.left    = x + 'px'
	webgl.style.top     = y + 'px'

	view.resize
		width        : params.width
		height       : params.height
		x            : x
		y            : y
		webgl_width  : params.webgl_width
		webgl_height : params.webgl_height

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


