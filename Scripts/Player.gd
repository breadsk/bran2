extends CharacterBody2D

@onready var anims = $AnimationPlayer
@onready var sprite = $Sprite2D


var velocidad = 100
var salto = 200
var gravedad = 400
var velocidad_dash = 350

#Variables de estado para no congelar el _physics_process
var haciendo_accion: bool = false
var en_dash: bool = false

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
		elif Input.is_action_just_pressed("dash"):
			var direccion = -1 if sprite.flip_h else 1
			
			#1. Reproduce la animación
			var factor_lentitud = 0.5
			anims.play("DASH",-1,factor_lentitud)
			
			#2. Obtenemos el tiempo total ajustado que durará la animación
			var duracion_real = anims.current_animation_length / factor_lentitud
			var distancia = 80 * direccion#Pixeles que recorrera
			
			#3. El Tween tomará ese nuevo tiempo 'duracion_real' para avanzar
			var tween = create_tween()
			tween.tween_property(self,"position:x",position.x + distancia,duracion_real).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			
			#4. Espera a que termine la animacion
			await anims.animation_finished
			
			#Restablecemos la velocidad normal de las animaciones 
			anims.speed_scale = 1.0
			
			
	move_and_slide()#mover y deslizar el cuerpo

	animaciones()
	
	
func _input(event):
	if Input.is_action_just_pressed("atacar") and is_on_floor():
		set_physics_process(false)#modificar
		anims.play("ATTACK")
		await anims.animation_finished
		set_physics_process(true)
	


#Tambien se va a ejecutar en bucle porque esta en el _physics_process
func animaciones():
	
	if velocity.x > 0:
		sprite.flip_h = false
		anims.play("RUN")
	elif velocity.x < 0:
		sprite.flip_h = true
		anims.play("RUN")
	else:
		anims.play("IDLE")
		
	if velocity.y < 0:
		anims.play("JUMP")
	elif velocity.y > 0:
		anims.play("FALL")
