extends Control
class_name BrainDebugSuite

@onready var sneeze_progress_bar: ProgressBar = %SneezeProgressBar

var parent : Brain
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_parent() is not Brain:
		queue_free()
	else:
		parent = get_parent()
		sneeze_progress_bar.max_value = parent.sneeze_trigger_target

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	sneeze_progress_bar.value = parent.sneeze_trigger_count.current_value
