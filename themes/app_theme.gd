@tool
extends ProgrammaticTheme

const UPDATE_SETTINGS = true
const VERBOSE = true

# Common theme variables
const default_font_size = 16
const corner_radius = 8
const border_width = 2
const padding = 8
const spacing = 20

# Current theme colors (will be set in setup_light/dark_theme)
var current_background_color: Color
var current_surface_color: Color
var current_primary_color: Color
var current_secondary_color: Color
var current_text_color: Color
var current_border_color: Color
var current_error_color: Color
var current_success_color: Color
var current_disabled_color: Color
var current_selected_color: Color

# Light theme colors
const light_background_color = Color(0.95, 0.95, 0.95, 1.0)
const light_surface_color = Color(1.0, 1.0, 1.0, 1.0)
const light_primary_color = Color(0.2, 0.4, 0.8, 1.0)
const light_secondary_color = Color(0.4, 0.6, 0.8, 1.0)
const light_text_color = Color(0.2, 0.2, 0.2, 1.0)
const light_border_color = Color(0.8, 0.8, 0.8, 1.0)
const light_error_color = Color(0.8, 0.2, 0.2, 1.0)
const light_success_color = Color(0.2, 0.8, 0.2, 1.0)
const light_disabled_color = Color(0.7, 0.7, 0.7, 1.0)
const light_selected_color = Color(0.9, 0.9, 0.9, 1.0)

# Dark theme colors
const dark_background_color = Color(0.1, 0.1, 0.15, 1.0)
const dark_surface_color = Color(0.2, 0.2, 0.2, 1.0)
const dark_primary_color = Color(0.4, 0.6, 0.8, 1.0)
const dark_secondary_color = Color(0.6, 0.8, 1.0, 1.0)
const dark_text_color = Color(0.9, 0.9, 0.9, 1.0)
const dark_border_color = Color(0.3, 0.3, 0.3, 1.0)
const dark_error_color = Color(0.8, 0.2, 0.2, 1.0)
const dark_success_color = Color(0.2, 0.8, 0.2, 1.0)
const dark_disabled_color = Color(0.3, 0.3, 0.3, 1.0)
const dark_selected_color = Color(0.3, 0.3, 0.3, 1.0)

func setup_light_theme():
	current_background_color = light_background_color
	current_surface_color = light_surface_color
	current_primary_color = light_primary_color
	current_secondary_color = light_secondary_color
	current_text_color = light_text_color
	current_border_color = light_border_color
	current_error_color = light_error_color
	current_success_color = light_success_color
	current_disabled_color = light_disabled_color
	current_selected_color = light_selected_color
	save_path = "res://themes/generated/light_theme.tres"

func setup_dark_theme():
	current_background_color = dark_background_color
	current_surface_color = dark_surface_color
	current_primary_color = dark_primary_color
	current_secondary_color = dark_secondary_color
	current_text_color = dark_text_color
	current_border_color = dark_border_color
	current_error_color = dark_error_color
	current_success_color = dark_success_color
	current_disabled_color = dark_disabled_color
	current_selected_color = dark_selected_color
	save_path = "res://themes/generated/dark_theme.tres"

func define_theme():
	# Set default font sizes
	set_default_font_size("font_size", default_font_size)
	
	# PanelContainer styles
	define_style("PanelContainer", "panel", {
		"background_color": current_surface_color,
		"border_width_left": border_width,
		"border_width_top": border_width,
		"border_width_right": border_width,
		"border_width_bottom": border_width,
		"border_color": current_border_color,
		"corner_radius_top_left": corner_radius,
		"corner_radius_top_right": corner_radius,
		"corner_radius_bottom_right": corner_radius,
		"corner_radius_bottom_left": corner_radius,
		"content_margin_left": padding,
		"content_margin_top": padding,
		"content_margin_right": padding,
		"content_margin_bottom": padding
	})
	
	# Button styles
	define_style("Button", "normal", {
		"background_color": current_surface_color,
		"border_width_left": border_width,
		"border_width_top": border_width,
		"border_width_right": border_width,
		"border_width_bottom": border_width,
		"border_color": current_border_color,
		"corner_radius_top_left": corner_radius,
		"corner_radius_top_right": corner_radius,
		"corner_radius_bottom_right": corner_radius,
		"corner_radius_bottom_left": corner_radius,
		"content_margin_left": padding,
		"content_margin_top": padding,
		"content_margin_right": padding,
		"content_margin_bottom": padding
	})
	
	define_style("Button", "hover", {
		"background_color": current_selected_color,
		"border_color": current_primary_color
	})
	
	define_style("Button", "pressed", {
		"background_color": current_primary_color,
		"border_color": current_primary_color
	})
	
	define_style("Button", "disabled", {
		"background_color": current_disabled_color,
		"border_color": current_disabled_color
	})
	
	# Label styles
	define_style("Label", "normal", {
		"background_color": Color(0, 0, 0, 0),
		"text_color": current_text_color
	})
	
	# LineEdit styles
	define_style("LineEdit", "normal", {
		"background_color": current_surface_color,
		"border_width_left": border_width,
		"border_width_top": border_width,
		"border_width_right": border_width,
		"border_width_bottom": border_width,
		"border_color": current_border_color,
		"corner_radius_top_left": corner_radius,
		"corner_radius_top_right": corner_radius,
		"corner_radius_bottom_right": corner_radius,
		"corner_radius_bottom_left": corner_radius,
		"content_margin_left": padding,
		"content_margin_top": padding,
		"content_margin_right": padding,
		"content_margin_bottom": padding
	})
	
	define_style("LineEdit", "focus", {
		"border_color": current_primary_color
	})
	
	# CheckBox styles
	define_style("CheckBox", "normal", {
		"background_color": current_surface_color,
		"border_width_left": border_width,
		"border_width_top": border_width,
		"border_width_right": border_width,
		"border_width_bottom": border_width,
		"border_color": current_border_color,
		"corner_radius_top_left": corner_radius,
		"corner_radius_top_right": corner_radius,
		"corner_radius_bottom_right": corner_radius,
		"corner_radius_bottom_left": corner_radius
	})
	
	define_style("CheckBox", "hover", {
		"border_color": current_primary_color
	})
	
	define_style("CheckBox", "pressed", {
		"background_color": current_selected_color
	})
	
	define_style("CheckBox", "checked", {
		"background_color": current_primary_color,
		"border_color": current_primary_color
	})
	
	define_style("CheckBox", "disabled", {
		"background_color": current_disabled_color,
		"border_color": current_disabled_color
	})
	
	# OptionButton styles
	define_style("OptionButton", "normal", {
		"background_color": current_surface_color,
		"border_width_left": border_width,
		"border_width_top": border_width,
		"border_width_right": border_width,
		"border_width_bottom": border_width,
		"border_color": current_border_color,
		"corner_radius_top_left": corner_radius,
		"corner_radius_top_right": corner_radius,
		"corner_radius_bottom_right": corner_radius,
		"corner_radius_bottom_left": corner_radius,
		"content_margin_left": padding,
		"content_margin_top": padding,
		"content_margin_right": padding,
		"content_margin_bottom": padding
	})
	
	define_style("OptionButton", "hover", {
		"border_color": current_primary_color
	})
	
	define_style("OptionButton", "pressed", {
		"background_color": current_selected_color
	})
	
	define_style("OptionButton", "disabled", {
		"background_color": current_disabled_color,
		"border_color": current_disabled_color
	})
	
	# ScrollContainer styles
	define_style("ScrollContainer", "panel", {
		"background_color": current_surface_color,
		"border_width_left": border_width,
		"border_width_top": border_width,
		"border_width_right": border_width,
		"border_width_bottom": border_width,
		"border_color": current_border_color,
		"corner_radius_top_left": corner_radius,
		"corner_radius_top_right": corner_radius,
		"corner_radius_bottom_right": corner_radius,
		"corner_radius_bottom_left": corner_radius
	})
	
	# VBoxContainer and HBoxContainer styles
	define_style("VBoxContainer", "panel", {
		"background_color": Color(0, 0, 0, 0)
	})
	
	define_style("HBoxContainer", "panel", {
		"background_color": Color(0, 0, 0, 0)
	})
	
	# ProgressBar styles
	define_style("ProgressBar", "background", {
		"background_color": current_surface_color,
		"border_width_left": border_width,
		"border_width_top": border_width,
		"border_width_right": border_width,
		"border_width_bottom": border_width,
		"border_color": current_border_color,
		"corner_radius_top_left": corner_radius,
		"corner_radius_top_right": corner_radius,
		"corner_radius_bottom_right": corner_radius,
		"corner_radius_bottom_left": corner_radius
	})
	
	define_style("ProgressBar", "fill", {
		"background_color": current_primary_color,
		"border_width_left": 0,
		"border_width_top": 0,
		"border_width_right": 0,
		"border_width_bottom": 0,
		"corner_radius_top_left": corner_radius,
		"corner_radius_top_right": corner_radius,
		"corner_radius_bottom_right": corner_radius,
		"corner_radius_bottom_left": corner_radius
	})
	
	# Label variations
	define_style("Label", "Title", {
		"font_size": default_font_size * 2,
		"text_color": current_text_color
	})
	
	define_style("Label", "Subtitle", {
		"font_size": default_font_size * 1.5,
		"text_color": current_text_color
	})
	
	# Button variations
	define_style("Button", "PrimaryButton", {
		"background_color": current_primary_color,
		"border_color": current_primary_color,
		"text_color": current_surface_color
	})
	
	define_style("Button", "SecondaryButton", {
		"background_color": current_surface_color,
		"border_color": current_primary_color,
		"text_color": current_primary_color
	})
	
	# PanelContainer variations
	define_style("PanelContainer", "Card", {
		"background_color": current_surface_color,
		"border_width_left": border_width,
		"border_width_top": border_width,
		"border_width_right": border_width,
		"border_width_bottom": border_width,
		"border_color": current_border_color,
		"corner_radius_top_left": corner_radius * 2,
		"corner_radius_top_right": corner_radius * 2,
		"corner_radius_bottom_right": corner_radius * 2,
		"corner_radius_bottom_left": corner_radius * 2,
		"content_margin_left": padding * 2,
		"content_margin_top": padding * 2,
		"content_margin_right": padding * 2,
		"content_margin_bottom": padding * 2
	}) 
