top.Satella  = require '../util/satella'
top.View     = require '../util/view'
top.riot     = require 'riot'
top.observer = riot.observable()

require '../component/js/application'
require '../component/js/title-bar'
require '../component/js/workspace'

# load -------------------------------------------------
window.addEventListener 'load', ->
	size = getSize()
	riot.mount 'application', size

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
	width  = if(width >= 1100) then width else 1100
	height = if(height >= 650) then height else 650
	size   = { width: width, height: height }

	return size