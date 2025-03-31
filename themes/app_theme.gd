@tool
extends ProgrammaticTheme

const UPDATE_ON_SAVE = true
const VERBOSITY = Verbosity.NORMAL

# Common theme variables
var default_font_size = 16
var padding = 8
var spacing = 4

# Colors for light theme
var light_background = Color("#FFFFFF")
var light_surface = Color("#F5F5F5")
var light_primary = Color("#2196F3")
var light_secondary = Color("#03A9F4")
var light_text = Color("#212121")
var light_text_secondary = Color("#757575")
var light_border = Color("#E0E0E0")
var light_error = Color("#F44336")
var light_success = Color("#4CAF50")
var light_disabled = Color("#BDBDBD")
var light_selected = Color("#E3F2FD")

# Colors for dark theme
var dark_background = Color("#121212")
var dark_surface = Color("#1E1E1E")
var dark_primary = Color("#64B5F6")
var dark_secondary = Color("#29B6F6")
var dark_text = Color("#FFFFFF")
var dark_text_secondary = Color("#B0B0B0")
var dark_border = Color("#333333")
var dark_error = Color("#EF5350")
var dark_success = Color("#81C784")
var dark_disabled = Color("#424242")
var dark_selected = Color("#1A237E")

# Current theme colors (will be set in setup)
var current_background: Color
var current_surface: Color
var current_primary: Color
var current_secondary: Color
var current_text: Color
var current_text_secondary: Color
var current_border: Color
var current_error: Color
var current_success: Color
var current_disabled: Color
var current_selected: Color

func setup_light_theme():
	set_save_path("res://themes/generated/light_theme.tres")
	
	# Set light theme colors
	current_background = light_background
	current_surface = light_surface
	current_primary = light_primary
	current_secondary = light_secondary
	current_text = light_text
	current_text_secondary = light_text_secondary
	current_border = light_border
	current_error = light_error
	current_success = light_success
	current_disabled = light_disabled
	current_selected = light_selected

func setup_dark_theme():
	set_save_path("res://themes/generated/dark_theme.tres")
	
	# Set dark theme colors
	current_background = dark_background
	current_surface = dark_surface
	current_primary = dark_primary
	current_secondary = dark_secondary
	current_text = dark_text
	current_text_secondary = dark_text_secondary
	current_border = dark_border
	current_error = dark_error
	current_success = dark_success
	current_disabled = dark_disabled
	current_selected = dark_selected

func define_theme():
	# Set default font size
	define_default_font_size(default_font_size)
	
	# Common style for panels and containers
	var panel_style = stylebox_flat({
		bg_color = current_surface,
		border_color = current_border,
		border_width_left = 1,
		border_width_top = 1,
		border_width_right = 1,
		border_width_bottom = 1,
		corner_radius_top_left = 4,
		corner_radius_top_right = 4,
		corner_radius_bottom_right = 4,
		corner_radius_bottom_left = 4,
		content_margin_left = padding,
		content_margin_top = padding,
		content_margin_right = padding,
		content_margin_bottom = padding
	})
	
	# Button styles
	var button_normal = stylebox_flat({
		bg_color = current_primary,
		border_color = current_border,
		border_width_left = 1,
		border_width_top = 1,
		border_width_right = 1,
		border_width_bottom = 1,
		corner_radius_top_left = 4,
		corner_radius_top_right = 4,
		corner_radius_bottom_right = 4,
		corner_radius_bottom_left = 4,
		content_margin_left = padding,
		content_margin_top = padding,
		content_margin_right = padding,
		content_margin_bottom = padding
	})
	
	var button_hover = inherit(button_normal, {
		bg_color = current_primary.lightened(0.1)
	})
	
	var button_pressed = inherit(button_normal, {
		bg_color = current_primary.darkened(0.1)
	})
	
	var button_disabled = inherit(button_normal, {
		bg_color = current_disabled,
		border_color = current_disabled
	})
	
	# CheckBox styles
	var checkbox_normal = stylebox_flat({
		bg_color = current_surface,
		border_color = current_border,
		border_width_left = 1,
		border_width_top = 1,
		border_width_right = 1,
		border_width_bottom = 1,
		corner_radius_top_left = 2,
		corner_radius_top_right = 2,
		corner_radius_bottom_right = 2,
		corner_radius_bottom_left = 2,
		content_margin_left = 2,
		content_margin_top = 2,
		content_margin_right = 2,
		content_margin_bottom = 2
	})
	
	var checkbox_checked = inherit(checkbox_normal, {
		bg_color = current_primary,
		border_color = current_primary
	})
	
	var checkbox_hover = inherit(checkbox_normal, {
		border_color = current_primary
	})
	
	# OptionButton styles
	var option_button_normal = stylebox_flat({
		bg_color = current_surface,
		border_color = current_border,
		border_width_left = 1,
		border_width_top = 1,
		border_width_right = 1,
		border_width_bottom = 1,
		corner_radius_top_left = 4,
		corner_radius_top_right = 4,
		corner_radius_bottom_right = 4,
		corner_radius_bottom_left = 4,
		content_margin_left = padding,
		content_margin_top = padding,
		content_margin_right = padding,
		content_margin_bottom = padding
	})
	
	var option_button_hover = inherit(option_button_normal, {
		border_color = current_primary
	})
	
	var option_button_pressed = inherit(option_button_normal, {
		bg_color = current_selected
	})
	
	# ScrollContainer styles
	var scroll_container_style = stylebox_flat({
		bg_color = current_surface,
		border_color = current_border,
		border_width_left = 1,
		border_width_top = 1,
		border_width_right = 1,
		border_width_bottom = 1,
		corner_radius_top_left = 4,
		corner_radius_top_right = 4,
		corner_radius_bottom_right = 4,
		corner_radius_bottom_left = 4
	})
	
	# Define styles for various nodes
	define_style("PanelContainer", {
		panel = panel_style
	})
	
	define_style("Button", {
		normal = button_normal,
		hover = button_hover,
		pressed = button_pressed,
		disabled = button_disabled,
		font_color = current_text,
		font_size = default_font_size
	})
	
	define_style("Label", {
		font_color = current_text,
		font_size = default_font_size,
		line_spacing = default_font_size / 4
	})
	
	define_style("LineEdit", {
		normal = stylebox_flat({
			bg_color = current_surface,
			border_color = current_border,
			border_width_left = 1,
			border_width_top = 1,
			border_width_right = 1,
			border_width_bottom = 1,
			corner_radius_top_left = 4,
			corner_radius_top_right = 4,
			corner_radius_bottom_right = 4,
			corner_radius_bottom_left = 4,
			content_margin_left = padding,
			content_margin_top = padding,
			content_margin_right = padding,
			content_margin_bottom = padding
		}),
		focus = stylebox_flat({
			bg_color = current_surface,
			border_color = current_primary,
			border_width_left = 2,
			border_width_top = 2,
			border_width_right = 2,
			border_width_bottom = 2,
			corner_radius_top_left = 4,
			corner_radius_top_right = 4,
			corner_radius_bottom_right = 4,
			corner_radius_bottom_left = 4,
			content_margin_left = padding,
			content_margin_top = padding,
			content_margin_right = padding,
			content_margin_bottom = padding
		}),
		font_color = current_text,
		font_size = default_font_size
	})
	
	define_style("CheckBox", {
		normal = checkbox_normal,
		hover = checkbox_hover,
		pressed = checkbox_normal,
		checked = checkbox_checked,
		checked_disabled = checkbox_checked,
		unchecked_disabled = checkbox_normal,
		font_color = current_text,
		font_size = default_font_size
	})
	
	define_style("OptionButton", {
		normal = option_button_normal,
		hover = option_button_hover,
		pressed = option_button_pressed,
		disabled = option_button_normal,
		font_color = current_text,
		font_size = default_font_size
	})
	
	define_style("ScrollContainer", {
		panel = scroll_container_style
	})
	
	# Define container styles
	define_style("VBoxContainer", {
		separation = spacing
	})
	
	define_style("HBoxContainer", {
		separation = spacing
	})
	
	# Define variations
	define_variant_style("Title", "Label", {
		font_size = default_font_size * 1.5,
		font_color = current_primary
	})
	
	define_variant_style("Subtitle", "Label", {
		font_size = default_font_size * 1.25,
		font_color = current_text_secondary
	})
	
	define_variant_style("Card", "PanelContainer", {
		panel = stylebox_flat({
			bg_color = current_surface,
			border_color = current_border,
			border_width_left = 1,
			border_width_top = 1,
			border_width_right = 1,
			border_width_bottom = 1,
			corner_radius_top_left = 8,
			corner_radius_top_right = 8,
			corner_radius_bottom_right = 8,
			corner_radius_bottom_left = 8,
			content_margin_left = padding * 2,
			content_margin_top = padding * 2,
			content_margin_right = padding * 2,
			content_margin_bottom = padding * 2
		})
	})
	
	define_variant_style("PrimaryButton", "Button", {
		normal = button_normal,
		hover = button_hover,
		pressed = button_pressed,
		disabled = button_disabled,
		font_color = current_text,
		font_size = default_font_size * 1.1
	})
	
	define_variant_style("SecondaryButton", "Button", {
		normal = stylebox_flat({
			bg_color = current_surface,
			border_color = current_primary,
			border_width_left = 1,
			border_width_top = 1,
			border_width_right = 1,
			border_width_bottom = 1,
			corner_radius_top_left = 4,
			corner_radius_top_right = 4,
			corner_radius_bottom_right = 4,
			corner_radius_bottom_left = 4,
			content_margin_left = padding,
			content_margin_top = padding,
			content_margin_right = padding,
			content_margin_bottom = padding
		}),
		hover = stylebox_flat({
			bg_color = current_selected,
			border_color = current_primary,
			border_width_left = 1,
			border_width_top = 1,
			border_width_right = 1,
			border_width_bottom = 1,
			corner_radius_top_left = 4,
			corner_radius_top_right = 4,
			corner_radius_bottom_right = 4,
			corner_radius_bottom_left = 4,
			content_margin_left = padding,
			content_margin_top = padding,
			content_margin_right = padding,
			content_margin_bottom = padding
		}),
		pressed = stylebox_flat({
			bg_color = current_primary,
			border_color = current_primary,
			border_width_left = 1,
			border_width_top = 1,
			border_width_right = 1,
			border_width_bottom = 1,
			corner_radius_top_left = 4,
			corner_radius_top_right = 4,
			corner_radius_bottom_right = 4,
			corner_radius_bottom_left = 4,
			content_margin_left = padding,
			content_margin_top = padding,
			content_margin_right = padding,
			content_margin_bottom = padding
		}),
		disabled = stylebox_flat({
			bg_color = current_surface,
			border_color = current_disabled,
			border_width_left = 1,
			border_width_top = 1,
			border_width_right = 1,
			border_width_bottom = 1,
			corner_radius_top_left = 4,
			corner_radius_top_right = 4,
			corner_radius_bottom_right = 4,
			corner_radius_bottom_left = 4,
			content_margin_left = padding,
			content_margin_top = padding,
			content_margin_right = padding,
			content_margin_bottom = padding
		}),
		font_color = current_primary,
		font_size = default_font_size
	})
	
	# Add some custom theme properties
	current_theme.set_color("primary", "Colors", current_primary)
	current_theme.set_color("secondary", "Colors", current_secondary)
	current_theme.set_color("error", "Colors", current_error)
	current_theme.set_color("success", "Colors", current_success)
	current_theme.set_color("text_secondary", "Colors", current_text_secondary)
	current_theme.set_color("disabled", "Colors", current_disabled)
	current_theme.set_color("selected", "Colors", current_selected) 
