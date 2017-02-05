class ModeControlsUI
	constructor: (app) ->
		@app = app

	##
	# 描画
	##
	render: ->
		style = @createStyle()
		app   = @createElement style
		@app.innerHTML = app

		@mode = @app.children[0]

		@bindEvent()          # イベントの紐付け
		@check app_state.mode # モードのチェック

	##
	# スタイルシートの生成
	##
	createStyle: ->
		style = "
			#mode-controls {
				float: left;
			}
			#mode-controls:after {
				content: \"\"; display: block; clear: both;
			}
			#mode-controls .mode {
				float: left;
			    width: 25px; height: 25px;
			    background-color: #444; margin-left: 1px;
			    background-position: center;
			    background-repeat: no-repeat;
			    background-size: auto 70%; cursor: pointer;
			}
			#mode-controls .mode:first-child {
				margin-left: 10px;
				border-top-left-radius: 3px;
			    border-bottom-left-radius: 3px;
			}
			#mode-controls .mode[data-state=\"active\"] { 
				box-shadow: 0 0 20px rgb(0,60,255) inset;
			}

			.mode-preview { background-image: url(../img/mode/preview.png); }
			.mode-pointer { background-image: url(../img/mode/pointer.png); }
			.mode-scale   { background-image: url(../img/mode/scale.png); }
			.mode-polygon { background-image: url(../img/mode/polygon.png); }
			.mode-collect { background-image: url(../img/mode/collect.png); }
			.mode-anchor  { background-image: url(../img/mode/anchor.png); }
			.mode-rotate  { background-image: url(../img/mode/rotate.png); }
			.mode-cubism  { background-image: url(../img/mode/cubism.png); }
			.mode-curve   { background-image: url(../img/mode/curve.png); }
			.mode-atari {
				border-top-right-radius: 3px;
			    border-bottom-right-radius: 3px;
			    background-image: url(../img/mode/atari.png);
			}
		".replace(/(\t|\n)/g, '')

		return style

	##
	# 要素の生成
	# @param style: スタイルシート
	##
	createElement: (style) ->
		app = "
			<div class=\"mode-box\">
				<div class=\"mode-preview mode\" title=\"preview\" data-state=\"\"></div>
				<div class=\"mode-pointer mode\" title=\"pointer\" data-state=\"\"></div>
				<div class=\"mode-scale mode\" title=\"scale\" data-state=\"\"></div>
				<div class=\"mode-polygon mode\" title=\"polygon\" data-state=\"\"></div>
				<div class=\"mode-collect mode\" title=\"collect\" data-state=\"\"></div>
				<div class=\"mode-anchor mode\"  title=\"anchor\"  data-state=\"\"></div>
				<div class=\"mode-rotate mode\"  title=\"rotate\"  data-state=\"\"></div>
				<div class=\"mode-cubism mode\"  title=\"cubism\"  data-state=\"\"></div>
				<div class=\"mode-curve mode\"  title=\"curve\"  data-state=\"\"></div>
				<div class=\"mode-atari mode\"   title=\"atari\"  data-state=\"\"></div>
			</div>
			<style>#{ style }</style>"

	##
	# イベントの紐付け
	##
	bindEvent: ->
		modes = @mode.children

		for mode in modes
			# click -----------------------------------------
			mode.addEventListener 'click', (e) =>
				m = e.target.title
				@check m 
				app_state.setState 'mode', m

			# mouseover -------------------------------------
			mode.addEventListener 'mouseover', (e) =>
				m = e.target.title
				@setHelp m, e.clientX, e.clientY

			# mouseout --------------------------------------
			mode.addEventListener 'mouseout', (e) =>
				UI.help.remove()

	##
	# ヘルプの表示
	# @param mode: モード
	# @param x:    x座標
	# @param y:    y座標
	##
	setHelp: (mode, x, y) ->
		title = description = ''
		switch mode
			when 'preview'
				title       = 'Preview'
				description = 'プレビューモードです。<br />何もアクションは起こしません。'
			when 'pointer'
				title       = 'Pointer'
				description = '移動モードです。<br />パーツを移動させることができます。'
			when 'scale'
				title       = 'Scale'
				description = '拡大縮小モードです。<br />パーツを拡大縮小させることができます。'
			when 'polygon'
				title       = 'Polygon'
				description = 'ポリゴンモードです。<br />ポリゴンを一つ一つ移動させることができます。'
			when 'collect'
				title       = 'Collect'
				description = 'コレクションモードです。<br />ポリゴンを複数同時に移動させることができます。'
			when 'anchor'
				title       = 'Anchor'
				description = 'アンカーポイントモードです。<br />アンカーポイントを移動させることができます。'
			when 'rotate'
				title       = 'Rotate'
				description = '回転モードです。<br />パーツを回転させることができます。'
			when 'cubism'
				title       = 'Cubism'
				description = '立体モードです。<br />パーツを立体的に見せる時に便利なモードです。'
			when 'curve'
				title       = 'Curve'
				description = '曲線モードです。<br />縦列横列のポリゴンを曲げることができます。'
			when 'atari'
				title       = 'Atari'
				description = 'アタリモードです。<br />アタリを決めることができるモードです。'

		UI.help.render({
			title:       title
			description: description
			x:           x
			y:           y
		})

	##
	# モードのチェック
	# @param m: モード
	##
	check: (m) ->
		modes = @mode.children

		for mode in modes
			_m = mode.title
			if m is _m
				mode.setAttribute 'data-state', 'active'
			else
				mode.setAttribute 'data-state', ''

module.exports = ModeControlsUI