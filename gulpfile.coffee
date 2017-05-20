gulp       = require 'gulp'
uglify     = require 'gulp-uglify'
riot       = require 'gulp-riot'
coffee     = require 'gulp-coffee'
plumber    = require 'gulp-plumber'
browserify = require 'browserify'
through2   = require 'through2'

# library
gulp.task 'library', ->
	gulp.src 'lib/*.coffee'
		.pipe plumber()
		.pipe coffee { bare: true }
		.pipe uglify()
		.pipe gulp.dest 'lib/'

# watch
gulp.task 'watch', ->
	gulp.watch [
		'lib/*.coffee'
	], ['library']