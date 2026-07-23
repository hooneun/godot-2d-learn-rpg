extends CharacterBody2D

@export_category("Stats")
@export var hitpoints: int = 180

func task_damage(amount: int) -> void:
	hitpoints -= amount
	if hitpoints < 0:
		death()

func death() -> void:
	queue_free()
