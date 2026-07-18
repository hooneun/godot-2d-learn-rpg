extends CharacterBody2D

enum State {
	IDLE,
	RUN,
	ATTACK
}

@export_category("Stats")
@export var speed = 400
@export var attack_speed = 0.6

var state: State = State.IDLE

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_playback: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]

func _ready() -> void:
	animation_tree.set_active(true)

	state = State.IDLE
	animation_playback.start("idle")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		attack()


func _physics_process(_delta: float) -> void:
	if state == State.ATTACK:
		return

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
		State.ATTACK:
			animation_playback.travel("attack")


func attack() -> void:
	if state == State.ATTACK:
		return
	state = State.ATTACK

	# get_global_mouse_position() -> 게임 전체 좌표 기준 마우스 위치
	# 캐릭터 위치: (300, 200)
	# 마우스 위치: (500, 200)
	# attack_dir -> 캐릭터 위치에서 마우스 위치까지의 방향 벡터
	# 마우스 위치:   (500, 200)
	# 캐릭터 위치:   (300, 200)
	# 빼기 결과:     (200, 0)
	# normalized() -> 방향 벡터의 크기를 1로 정규화 = Vector2(1,0)
	# 오른쪽: (1, 0)
	# 왼쪽:   (-1, 0)
	# 위쪽:   (0, -1)
	# 아래쪽: (0, 1)
	var mouse_pos: Vector2 = get_global_mouse_position()
	var attack_dir: Vector2 = (mouse_pos - global_position).normalized()

	if abs(attack_dir.x) >= abs(attack_dir.y):
		sprite.flip_h = attack_dir.x < 0.0


	animation_tree.set("parameters/attack/BlendSpace2D/blend_position", attack_dir)

	update_animation()

	# attack_speed -> 공격 속도
	# 0.6 초 기다림
	# 다음 코드 실행
	await  get_tree().create_timer(attack_speed).timeout
	state = State.IDLE
	update_animation()
