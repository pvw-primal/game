class_name BasicColorPicker
extends ColorPickerButton

@onready var randomButton : BaseButton = get_node("Randomize")
static var possibleText : Array[String] = ["o", "p", "q", "r", "s", "t"]

func _ready():
	var p : ColorPicker = get_picker()
	p.color_modes_visible = false
	p.color_mode = ColorPicker.MODE_OKHSL
	p.picker_shape = ColorPicker.SHAPE_OKHSL_CIRCLE
	p.sliders_visible = false
	p.hex_visible = false
	p.can_add_swatches = false
	p.deferred_mode = true
	p.presets_visible = false
	p.sampler_visible = false
	p.custom_minimum_size = Vector2(275, 210)
	
	randomButton.button_down.connect(Randomize)

func Randomize():
	color = Color(randf(), randf(), randf())
	color_changed.emit(color)
	randomButton.text = possibleText[randi_range(0, possibleText.size() - 1)]
