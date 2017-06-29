gulp       = require 'gulp'
uglify     = require 'gulp-uglify'
riot       = require 'gulp-riot'
coffee     = require 'gulp-coffee'
plumber    = require 'gulp-plumber'
browserify = require 'browserify'
source     = require 'vinyl-source-stream'

# library
gulp.task 'library', ->
	gulp.src 'public/scripts/utils/coffee/*.coffee'
		.pipe plumber()
		.pipe coffee { bare: true }
		.pipe uglify()
		.pipe gulp.dest 'public/scripts/utils/js'

# bin
gulp.task 'bin', ['library'], ->
	gulp.src 'bin/coffee/*.coffee'
		.pipe plumber()
		.pipe coffee()
		.pipe uglify()
		.pipe gulp.dest 'bin/js'

# riot
gulp.task 'riot', ['bin'], ->
	gulp.src 'public/scripts/components/tag/*.tag'
		.pipe plumber()
		.pipe riot
			compact  : true
			template : 'pug'
			type     : 'coffeescript'
		.pipe gulp.dest 'public/scripts/components/js'

# core
gulp.task 'core', ['riot'], ->
	gulp.src 'public/scripts/core.coffee'
		.pipe plumber()
		.pipe coffee { bare: true }
		.pipe uglify()
		.pipe gulp.dest 'public/scripts/lib'

# browserify
gulp.task 'browserify', ['core'], ->
	browserify 'public/scripts/lib/core.js'
		.bundle()
		.pipe source 'core.js'
		.pipe gulp.dest 'public/scripts/lib'

# default
gulp.task 'default', ['library', 'bin', 'riot', 'core', 'browserify']

# watch
gulp.task 'watch', ->
	gulp.watch [
		'public/scripts/*.coffee'
		'bin/coffee/*.coffee'
		'public/scripts/component/tag/*.tag'
		'public/scripts/core.coffee'
	], ['library', 'bin', 'riot', 'core', 'browserify']


