extends CharacterBody2D

enum State {
	IDLE,
	RUN,
}

@export_category("Stats")
@export var speed = 400

var state: State = State.IDLE

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_playback: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]


func _physics_process(_delta: float) -> void:
	var input_direction := Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed
	move_and_slide()

	if state == State.IDLE or state == State.RUN:
		if input_direction.x < -0.01:
			$Sprite2D.flip_h = true
		elif input_direction.x > 0.01:
			$Sprite2D.flip_h = false

	if input_direction != Vector2.ZERO and state == State.IDLE:
		state = State.RUN
		update_animation()
	elif input_direction == Vector2.ZERO and state == State.RUN:
		state = State.IDLE
		update_animation()

func update_animation() -> void:
	match state:
		State.IDLE:
			animation_playback.travel("idle")
		State.RUN:
			animation_playback.travel("run")
