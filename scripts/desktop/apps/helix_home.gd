extends ScrollContainer

func _ready() -> void:
	find_child("NavHome", true, false).pressed.connect(func(): GlobalSignals.navigator_navigate.emit("helixsolutions.com"))
	find_child("NavAbout", true, false).pressed.connect(func(): GlobalSignals.navigator_navigate.emit("helixsolutions.com/about"))
	find_child("NavServices", true, false).pressed.connect(func(): GlobalSignals.navigator_navigate.emit("helixsolutions.com/services"))
	find_child("NavTeam", true, false).pressed.connect(func(): GlobalSignals.navigator_navigate.emit("helixsolutions.com/team"))
	find_child("NavContact", true, false).pressed.connect(func(): GlobalSignals.navigator_navigate.emit("helixsolutions.com/contact"))