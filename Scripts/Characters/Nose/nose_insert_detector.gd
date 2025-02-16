extends Area2D
class_name NoseInsertDetector

var tracked_dict = {}

@export var insert_mask: Polygon2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("body_entered",on_body_entered)
	connect("body_exited",on_body_exited)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	for body in tracked_dict:
		var sprite = tracked_dict[body]
		#Move the sprite that used to belong to the body, to the current body position.
		sprite.global_position = body.global_position
		sprite.rotation = body.global_rotation

func on_body_entered(body):
	if body is SneezeTool:
		if body.InsertSprite:
			body.on_nose_insert()

			tracked_dict[body] = body.InsertSprite
			
			#Transfer ownership to the Clip Mask
			body.InsertSprite.reparent(insert_mask)
			
func on_body_exited(body):
	if body is SneezeTool:
		#test_clip_sprite.reparent(insert_mask)
		if tracked_dict.has(body):
			body.on_nose_remove()
			
			var sprite = tracked_dict[body]
			
			#Add child back to the tracked body instead of the clip mask.
			sprite.reparent(body)
			sprite.position = Vector2.ZERO
			sprite.rotation = 0.0
			
			#Remove body from tracking
			tracked_dict.erase(body)
			
			
