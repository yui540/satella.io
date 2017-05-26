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
require '../component/js/parameter-slider'

# load -------------------------------------------------
window.addEventListener 'load', ->
	size = getSize()
	riot.mount 'application', size

	satella.on 'add', ->
		satella.render()

# resize -----------------------------------------------
window.addEventListener 'resize', ->
	size = getSize()
	observer.trigger 'resize', size

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