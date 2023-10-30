extends Camera3D
const SPEED : float = 50
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_key_pressed(KEY_I):
		position.z += SPEED * delta
	if Input.is_key_pressed(KEY_K):
		position.z -= SPEED * delta
	if Input.is_key_pressed(KEY_J):
		position.x += SPEED * delta
	if Input.is_key_pressed(KEY_L):
		position.x -= SPEED * delta
	
