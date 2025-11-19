#!/usr/bin/env python3
"""
Create a selection circle sprite for units.
"""

from PIL import Image, ImageDraw

# Create selection circle (64x64 with transparent center)
img = Image.new('RGBA', (64, 64), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

# Draw green circle outline
draw.ellipse([4, 4, 60, 60], outline=(0, 255, 0, 200), width=3)

img.save("assets/sprites/selection_circle.png")
print("Selection circle created: assets/sprites/selection_circle.png")
