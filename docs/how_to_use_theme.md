# How to Apply the Theme to UI Elements

This guide explains how to apply the customized theme to different UI elements in your Godot project.

## Setting Up Project-wide Theme

To apply the theme to your entire project:

1. Go to Project → Project Settings
2. Select the "GUI" category on the left
3. Under "Theme", change "Custom" to your theme file: `res://assets/ui/default_theme.tres`
4. Click "OK" to save changes

## Applying Theme to Individual Scenes

If you want to apply the theme only to specific UI elements:

1. Select a Control node in your scene (Button, Label, Panel, etc.)
2. In the Inspector panel, locate the "Theme" section
3. Click on the dropdown next to "Theme" and select "Load"
4. Navigate to and select your theme file: `res://assets/ui/default_theme.tres`

## Creating UI Elements with Your Theme

Here's a simple example of creating a styled UI dialog:

1. Create a new scene with a `PanelContainer` as the root
2. Apply your theme to the PanelContainer
3. Add a VBoxContainer as a child of the PanelContainer
4. Set appropriate margins in the VBoxContainer (e.g., 20 pixels on all sides)
5. Add a Label, some content nodes, and Buttons as children of the VBoxContainer

Example hierarchy:
```
PanelContainer (themed)
└── VBoxContainer (margins: 20px)
    ├── Label (title)
    ├── TextureRect (icon/image)  
    ├── Label (description)
    └── HBoxContainer (button container)
        ├── Button ("Cancel")
        └── Button ("OK")
```

## Overriding Theme Elements

You can override specific theme elements for individual controls:

1. Select the control in the editor
2. In the Inspector, expand the "Theme Overrides" section
3. Override colors, fonts, styles, or constants as needed

For example, to make a specific button stand out:
- Expand "Theme Overrides" → "Styles"
- Set "Normal" to a new StyleBoxFlat with a different color

## Common UI Elements and Their Properties

### Buttons
- Set text via the "Text" property
- Add icons via the "Icon" property
- Adjust alignment with "Horizontal Alignment" and "Vertical Alignment"

### Labels
- Set text via the "Text" property
- Control wrapping with "Autowrap" (enable for multi-line text)
- Adjust alignment with "Horizontal Alignment" and "Vertical Alignment"

### Panels
- Adjust the size to fit your content
- Use anchors and margins to control positioning and responsiveness

## Creating Dynamic UI with Code

You can also create and theme UI elements via code:

```gdscript
func create_notification(title, message):
    # Create a panel with the theme
    var panel = PanelContainer.new()
    panel.theme = load("res://assets/ui/default_theme.tres")
    
    # Create a vertical container
    var vbox = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 10)
    panel.add_child(vbox)
    
    # Add a title label
    var title_label = Label.new()
    title_label.text = title
    title_label.add_theme_font_size_override("font_size", 24)
    vbox.add_child(title_label)
    
    # Add message label
    var message_label = Label.new()
    message_label.text = message
    message_label.autowrap = true
    vbox.add_child(message_label)
    
    # Add button
    var button = Button.new()
    button.text = "OK"
    button.connect("pressed", self, "_on_notification_closed", [panel])
    vbox.add_child(button)
    
    # Add to scene
    add_child(panel)
    
    return panel
``` 