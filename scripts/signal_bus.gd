extends Node


@warning_ignore_start("unused_signal")


signal targeting_rects_updated(rects : Dictionary, primary_target : CollisionObject3D, target_aquisition : float)
signal targeting_aquisition_rect_updated(rect : Rect2)
signal target_spawned(target : CollisionObject3D)
signal target_despawned(target : CollisionObject3D)
signal target_shot_at(target : CollisionObject3D)
