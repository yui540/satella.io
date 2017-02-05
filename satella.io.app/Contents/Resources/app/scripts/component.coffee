ui = 
	AppState:      '/app-state.coffee'
	View:          '/ui/view.ui.js'
	Scroll:        '/ui/scroll.ui.coffee'
	LayerCell:     '/ui/layer-cell.ui.coffee'
	LayerPanel:    '/ui/layer-panel.ui.coffee'
	ImageView:     '/ui/image-view.ui.coffee'
	SaveTexture:   '/ui/save-texture.ui.coffee'
	Timeline:      '/ui/timeline.ui.coffee'
	Tool:          '/ui/tool.ui.coffee'
	PutKeyframe:   '/ui/put-keyframe.ui.coffee'
	ModeControls:  '/ui/mode-controls.ui.coffee'
	ModeNavigator: '/ui/mode-navigator.ui.coffee'
	Tabs:          '/ui/tabs.ui.coffee'
	History:       '/ui/history.ui.coffee'
	Help:          '/ui/help.ui.coffee'
	ContextMenu:   '/ui/contextmenu.ui.coffee'
	Notification:  '/ui/notification.ui.coffee'
	Slider:        '/ui/slider.ui.coffee'
	Graph:         '/ui/graph.ui.coffee'
	Controls:      '/ui/controls.ui.coffee'
	Status:        '/ui/status.ui.coffee'
	AddParameter:  '/ui/add-parameter-view.ui.coffee'
	ParameterInfo: '/ui/parameter-info.ui.coffee'
	ParameterPanel:'/ui/parameter-panel.ui.coffee'
	AnimationPanel:'/ui/animation-panel.ui.coffee'
	ProjectPanel:  '/ui/project-panel.ui.coffee'
	Thumb:         '/ui/thumb.ui.coffee'
	SideBar:       '/ui/sidebar.ui.coffee'
	OpenList:      '/ui/open-list.ui.coffee'
	Top:           '/ui/top.ui.coffee'
	Save:          '/ui/save.ui.coffee'

compoments = {}
for name, file_name of ui
	compoments[name] = require __dirname + file_name

module.exports = compoments