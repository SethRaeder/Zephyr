extends Node

var particle_scene : PackedScene = preload("uid://dqwox1s5gwlb8")

@onready var world : World = $World
func _ready() -> void:
	ECS.world = world
	#character = preload("res://scenes/ecs_character_test.tscn").instantiate()
	
	var entities = find_children("*","Entity") as Array[Entity]
	world.add_entities(entities)
	print("Added entities : ",entities)
	var systems = find_children("*","System") as Array[System]
	world.add_systems(systems)
	print("Added systems : ",systems)
	

func _process(delta: float) -> void:
	if ECS.world:
		ECS.world.process(delta)

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var particle : Particle = particle_scene.instantiate()
		particle.position = get_window().get_mouse_position() + Vector2(randf_range(-10,10),randf_range(-10,10))

		add_child(particle)
		ECS.world.add_entity(particle)
