extends Node

# Theme configuration
var _theme: Theme = Theme.new()
var _font: Font = null
var _font_size: int = 16
var _primary_color: Color = Color(0.2, 0.2, 0.2)
var _secondary_color: Color = Color(0.3, 0.3, 0.3)
var _accent_color: Color = Color(0.4, 0.4, 0.4)
var _text_color: Color = Color(1, 1, 1)
var _button_hover_color: Color = Color(0.5, 0.5, 0.5)
var _button_pressed_color: Color = Color(0.6, 0.6, 0.6)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_load_font()
	_setup_theme()

func _load_font() -> void:
	# Load the default font
	_font = ThemeDB.fallback_font

func _setup_theme() -> void:
	# Set up the theme with default styles
	_setup_button_style()
	_setup_label_style()
	_setup_panel_style()
	_setup_line_edit_style()

func _setup_button_style() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = _primary_color
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	
	var hover_style := style.duplicate() as StyleBoxFlat
	hover_style.bg_color = _button_hover_color
	
	var pressed_style := style.duplicate() as StyleBoxFlat
	pressed_style.bg_color = _button_pressed_color
	
	_theme.set_stylebox("normal", "Button", style)
	_theme.set_stylebox("hover", "Button", hover_style)
	_theme.set_stylebox("pressed", "Button", pressed_style)
	_theme.set_font("font", "Button", _font)
	_theme.set_font_size("font_size", "Button", _font_size)
	_theme.set_color("font_color", "Button", _text_color)

func _setup_label_style() -> void:
	_theme.set_font("font", "Label", _font)
	_theme.set_font_size("font_size", "Label", _font_size)
	_theme.set_color("font_color", "Label", _text_color)

func _setup_panel_style() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = _secondary_color
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	
	_theme.set_stylebox("panel", "Panel", style)

func _setup_line_edit_style() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = _secondary_color
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	
	_theme.set_stylebox("normal", "LineEdit", style)
	_theme.set_stylebox("focus", "LineEdit", style)
	_theme.set_font("font", "LineEdit", _font)
	_theme.set_font_size("font_size", "LineEdit", _font_size)
	_theme.set_color("font_color", "LineEdit", _text_color)

# Public methods to get theme and update styles
func get_theme() -> Theme:
	return _theme

func update_primary_color(color: Color) -> void:
	_primary_color = color
	_setup_button_style()

func update_secondary_color(color: Color) -> void:
	_secondary_color = color
	_setup_panel_style()
	_setup_line_edit_style()

func update_accent_color(color: Color) -> void:
	_accent_color = color
	# Update any accent-colored elements here

func update_text_color(color: Color) -> void:
	_text_color = color
	_setup_button_style()
	_setup_label_style()
	_setup_line_edit_style()

func update_font_size(size: int) -> void:
	_font_size = size
	_setup_button_style()
	_setup_label_style()
	_setup_line_edit_style() 