extends CharacterBody2D

var velocidad = 100
var salto = 200
var gravedad = 400


#procesador de fisicas
#es un bucle que se repita cada delta tiempo
func _physics_process(delta):
	if Input.is_action_pressed("derecha"):
		velocity.x = velocidad
		pass
	elif Input.is_action_pressed("izquierda"):
		velocity.x = -velocidad
	else:
		velocity.x = 0
		
	move_and_slide()#mover y deslizar el cuerpo
