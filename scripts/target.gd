extends CollisionShape3D


signal destroyed()


func _ready() -> void:
	SignalBus.target_spawned.emit(self)
	SignalBus.target_shot_at.connect(on_target_shot_at)


func _exit_tree() -> void:
	SignalBus.target_despawned.emit(self)
	SignalBus.target_shot_at.disconnect(on_target_shot_at)


func on_target_shot_at(target: CollisionShape3D):
	if (target == self):
		destroyed.emit()
