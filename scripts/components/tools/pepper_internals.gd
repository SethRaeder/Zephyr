extends RigidBody2D

@onready var bottle_center: Node2D = $".."
@onready var pepper_internals_collision: CollisionShape2D = $PepperInternalsCollision

var amount = 1.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	pepper_internals_collision.shape.radius = 100.0
	
	var children = get_children()
	var distance = position.length()
	for i in range(children.size()):
		if children[i] is Sprite2D:
			var alpha = clamp(lerp(0.9,1.0,distance/200),0.9,1.0)
		
			children[i].modulate.a = alpha;
			if i%2 == 0:
				children[i].rotation += 0.005*(linear_velocity.length()) * delta;
			else:
				children[i].rotation -= 0.005*(linear_velocity.length()) * delta;
