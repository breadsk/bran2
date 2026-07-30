extends CharacterBody2D

var velocidad = 100
var salto = 200
var gravedad = 400


#procesador de fisicas
#es un bucle que se repita cada delta tiempo
func _physics_process(delta):
	
	velocity.y += gravedad*delta
	#Mientras yo tenga presionada la tecla
	if Input.is_action_pressed("derecha"):
		velocity.x = velocidad
	elif Input.is_action_pressed("izquierda"):
		velocity.x = -velocidad
	else:
		velocity.x = 0
		
	if is_on_floor():
		#solo se basta que se presione
		if Input.is_action_just_pressed("saltar"):
			velocity.y = -salto
		
	move_and_slide()#mover y deslizar el cuerpo

	animaciones()
	
#Tambien se va a ejecutar en bucle porque esta en el _physics_process
func animaciones():
	
	if velocity.x > 0:
		$Sprite2D.flip_h = false
		$AnimationPlayer.play("RUN")
	elif velocity.x < 0:
		$Sprite2D.flip_h = true
		$AnimationPlayer.play("RUN")
	else:
		$AnimationPlayer.play("IDLE")
		
	if velocity.y < 0:
		$AnimationPlayer.play("JUMP")
	elif velocity.y > 0:
		$AnimationPlayer.play("FALL")
