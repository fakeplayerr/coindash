# Theme Customization Guide

This guide explains how to customize the default theme with your own UI atlas textures and fonts.

## Project Structure

First, make sure your assets are organized correctly:

```
assets/
├── fonts/
│   └── main_font.ttf      # Your main font file (TTF or OTF)
└── ui/
    └── ui_atlas.png       # Your UI texture atlas
```

## Setting Up Your Atlas Texture

1. Import your UI atlas texture into the `assets/ui/` folder
2. Make sure to set appropriate import settings:
   - For pixel art: disable filter and mipmaps
   - For UI: enable repeat and adjust the compression as needed

## Customizing the Theme

Open the `assets/ui/default_theme.tres` file in Godot Editor:

1. **Update Font**:
   - Replace the reference to `main_font.ttf` with your own font file

2. **Configure Atlas Regions**:
   - For each UI element, update the `region` parameters to match your atlas layout
   - The format is `Rect2(x, y, width, height)` where:
     - `x, y`: Top-left position of the element in your atlas
     - `width, height`: Size of the element

3. **Key Regions to Update**:
   - Button Normal: `Rect2(0, 0, 64, 64)` - Normal button state
   - Button Hover: `Rect2(64, 0, 64, 64)` - When mouse hovers over button
   - Button Pressed: `Rect2(128, 0, 64, 64)` - When button is clicked
   - Button Disabled: `Rect2(192, 0, 64, 64)` - Disabled button state
   - Panel Background: `Rect2(0, 64, 64, 64)` - Background for panels

4. **Texture Margins**:
   - Update `texture_margin_left/top/right/bottom` for proper 9-slice stretching
   - These values determine which parts of your texture stretch and which remain fixed

## Adding More UI Elements

To add styles for more UI elements:

1. Add new AtlasTexture entries for each element
2. Create StyleBoxTexture resources using those AtlasTexture entries
3. Add them to the theme under appropriate categories

Example for adding a custom DialogPanel:

```gdscript
# Create AtlasTexture for dialog panel
[sub_resource type="AtlasTexture" id="AtlasTexture_dialog"]
atlas = ExtResource("1_wxngu")
region = Rect2(0, 128, 64, 64) # Your dialog panel region

# Create StyleBox for the dialog
[sub_resource type="StyleBoxTexture" id="StyleBoxTexture_dialog"]
texture = SubResource("AtlasTexture_dialog")
texture_margin_left = 15.0
texture_margin_top = 15.0
texture_margin_right = 15.0
texture_margin_bottom = 15.0

# Add to theme resource
PanelContainer/styles/panel = SubResource("StyleBoxTexture_dialog")
```

## Applying the Theme

To apply the theme to your entire project:

1. Go to Project Settings → GUI → Theme
2. Select Custom Theme and choose your `default_theme.tres`

To apply to a single control:
1. Select the control in the editor
2. In the Inspector, under "Theme", set your theme resource

## Color Scheme

Update the colors in the theme resource to match your game's color scheme:

```gdscript
Button/colors/font_color = Color(0.9, 0.9, 0.9, 1)
Button/colors/font_hover_color = Color(1, 1, 1, 1)
``` 