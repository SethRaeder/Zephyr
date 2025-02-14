extends Area2D

func _on_body_exited(body):
	if body is RigidBody2D:
		print("Unfreeze: ",body)
		body.freeze = false


func _on_body_entered(body):
	if body is RigidBody2D:
		print("Freeze: ",body)
		body.freeze = true
	
