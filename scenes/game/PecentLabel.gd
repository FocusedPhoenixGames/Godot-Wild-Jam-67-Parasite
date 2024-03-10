extends Label


func _ready() -> void:
	# The percentage may change when map is updated.
	MetSys.map_updated.connect(update)


func _notification(what: int) -> void:
	# Update when the label is made visible. This happens when the map is toggled.
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		update()


func update():
	# Only update when visible.
	if is_visible_in_tree():
		# Show the percentage.
		text = "%03d%%" % int(MetSys.get_explored_ratio() * 100)
