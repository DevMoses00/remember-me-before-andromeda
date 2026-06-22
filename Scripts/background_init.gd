extends Sprite2D

@export var anim_player : AnimationPlayer

func _ready():
	anim_player.play("wiggle")
	#await get_tree().create_timer(2.0).timeout
	#anim_player.stop()
	#self.position.x = 0  # Optional reset
