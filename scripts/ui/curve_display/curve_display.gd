extends VBoxContainer

@onready var label: Label = %Label
@onready var curve_editor: CurveEditor = %CurveEditor

func setup(label_text : String, curve : Curve):
	label.text = label_text
	curve_editor.set_curve(curve)
