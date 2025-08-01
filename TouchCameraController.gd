extends Camera3D

# Configurações de sensibilidade
@export var mouse_sensitivity: float = 0.003
@export var touch_sensitivity: float = 0.005

# Limites de rotação vertical (em radianos)
@export var min_pitch: float = -1.5
@export var max_pitch: float = 1.5

# Variáveis internas
var rotation_x: float = 0.0
var rotation_y: float = 0.0
var is_touching: bool = false
var last_touch_position: Vector2

func _ready():
	# Configura o input para capturar eventos de toque
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	# Controle com mouse (para desktop)
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		handle_mouse_movement(event.relative)
	
	# Controle com toque (para mobile)
	elif event is InputEventScreenTouch:
		handle_touch_event(event)
	
	elif event is InputEventScreenDrag:
		handle_touch_drag(event)
	
	# Liberar/capturar cursor com ESC
	elif event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func handle_mouse_movement(relative_movement: Vector2):
	# Aplica rotação horizontal (yaw)
	rotation_y -= relative_movement.x * mouse_sensitivity
	
	# Aplica rotação vertical (pitch) com limites
	rotation_x -= relative_movement.y * mouse_sensitivity
	rotation_x = clamp(rotation_x, min_pitch, max_pitch)
	
	# Aplica as rotações à câmera
	apply_rotation()

func handle_touch_event(event: InputEventScreenTouch):
	if event.pressed:
		is_touching = true
		last_touch_position = event.position
	else:
		is_touching = false

func handle_touch_drag(event: InputEventScreenDrag):
	if is_touching:
		var delta = event.position - last_touch_position
		last_touch_position = event.position
		
		# Aplica rotação horizontal (yaw)
		rotation_y -= delta.x * touch_sensitivity
		
		# Aplica rotação vertical (pitch) com limites
		rotation_x -= delta.y * touch_sensitivity
		rotation_x = clamp(rotation_x, min_pitch, max_pitch)
		
		# Aplica as rotações à câmera
		apply_rotation()

func apply_rotation():
	# Aplica a rotação à câmera
	transform.basis = Basis()
	rotate_y(rotation_y)
	rotate_object_local(Vector3(1, 0, 0), rotation_x)

# Função para resetar a rotação (opcional)
func reset_rotation():
	rotation_x = 0.0
	rotation_y = 0.0
	apply_rotation()

# Função para definir sensibilidade dinamicamente
func set_sensitivity(mouse_sens: float, touch_sens: float):
	mouse_sensitivity = mouse_sens
	touch_sensitivity = touch_sens