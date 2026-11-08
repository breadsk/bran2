extends CharacterBody2D

@onready var anims = $AnimationPlayer
@onready var sprite = $Sprite2D

var velocidad = 100
var salto = 200
var gravedad = 400

# Banderas para controlar el estado
var haciendo_accion: bool = false
var en_dash: bool = false
var dash_tween: Tween = null # Referencia para controlar/cancelar el Tween

func _physics_process(delta):
	# Aplicar gravedad
	velocity.y += gravedad * delta
	
	# Detectar interrupciones del dash
	if en_dash:
		if Input.is_action_just_pressed("saltar"):
			cancelar_dash()
			velocity.y = -salto # Salto inmediato
		elif Input.is_action_just_pressed("derecha") or Input.is_action_just_pressed("izquierda"):
			cancelar_dash() # Se cancela el dash y vuelve al control normal

	# Solo permitimos movimiento por teclado si NO está haciendo una acción (dash/ataque)
	if not haciendo_accion:
		if Input.is_action_pressed("derecha"):
			velocity.x = velocidad
		elif Input.is_action_pressed("izquierda"):
			velocity.x = -velocidad
		else:
			velocity.x = 0
			
		if is_on_floor():
			if Input.is_action_just_pressed("saltar"):
				velocity.y = -salto
			elif Input.is_action_just_pressed("dash"):
				ejecutar_dash()

	move_and_slide()

	# Solo actualizamos animaciones básicas si no hay una acción especial en curso
	if not haciendo_accion:
		animaciones()


func _input(event):
	if Input.is_action_just_pressed("atacar") and is_on_floor() and not haciendo_accion:
		ejecutar_ataque()


func ejecutar_dash():
	haciendo_accion = true
	en_dash = true
	velocity.x = 0
	
	var direccion = -1 if sprite.flip_h else 1
	var factor_lentitud = 0.5
	
	anims.play("DASH", -1, factor_lentitud)
	
	var duracion_real = anims.current_animation_length / factor_lentitud
	var distancia = 80 * direccion
	
	# Creamos el tween y guardamos la referencia en la variable global
	dash_tween = create_tween()
	dash_tween.tween_property(self, "position:x", position.x + distancia, duracion_real).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	await anims.animation_finished
	
	# Si terminó de forma natural (sin cancelarse)
	if en_dash:
		limpiar_estado_dash()


# Función unificada para cancelar el dash de forma limpia
func cancelar_dash():
	if dash_tween and dash_tween.is_running():
		dash_tween.kill()
	limpiar_estado_dash()


# Restaura las variables de estado
func limpiar_estado_dash():
	en_dash = false
	haciendo_accion = false


func ejecutar_ataque():
	haciendo_accion = true
	velocity.x = 0
	anims.play("ATTACK")
	await anims.animation_finished
	haciendo_accion = false


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
