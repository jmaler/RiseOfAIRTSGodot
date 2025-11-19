#!/usr/bin/env python3
"""
Generate simple sprite assets for the RTS game.
Creates basic colored shapes representing units and tiles.
"""

from PIL import Image, ImageDraw, ImageFont
import os

# Create directories if they don't exist
os.makedirs("assets/sprites/units", exist_ok=True)
os.makedirs("assets/sprites/tiles", exist_ok=True)

# Tile sprites (64x64)
def create_tile(filename, base_color, accent_color=None, pattern="solid"):
    img = Image.new('RGBA', (64, 64), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    if pattern == "solid":
        draw.rectangle([0, 0, 63, 63], fill=base_color)
    elif pattern == "forest":
        # Base grass
        draw.rectangle([0, 0, 63, 63], fill=base_color)
        # Trees (circles)
        for x, y in [(16, 16), (48, 16), (16, 48), (48, 48), (32, 32)]:
            draw.ellipse([x-8, y-8, x+8, y+8], fill=accent_color)
    elif pattern == "stone":
        # Rocky texture
        draw.rectangle([0, 0, 63, 63], fill=base_color)
        # Stone chunks
        for x, y, size in [(10, 10, 12), (45, 15, 10), (20, 40, 14), (50, 50, 8)]:
            draw.ellipse([x, y, x+size, y+size], fill=accent_color)
    elif pattern == "gold":
        # Gold mine
        draw.rectangle([0, 0, 63, 63], fill=base_color)
        # Gold nuggets
        draw.rectangle([16, 16, 48, 48], fill=accent_color)
        draw.polygon([(32, 12), (24, 24), (40, 24)], fill=accent_color)

    img.save(filename)
    print(f"Created {filename}")

# Unit sprites (48x48)
def create_unit(filename, color, unit_type):
    img = Image.new('RGBA', (48, 48), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    if unit_type == "worker":
        # Simple person with tool
        draw.ellipse([14, 8, 34, 28], fill=color)  # Head
        draw.rectangle([18, 28, 30, 44], fill=color)  # Body
        draw.line([18, 32, 8, 42], fill=(139, 69, 19), width=3)  # Tool

    elif unit_type == "soldier":
        # Person with shield
        draw.ellipse([14, 8, 34, 28], fill=color)  # Head
        draw.rectangle([18, 28, 30, 44], fill=color)  # Body
        draw.rectangle([8, 24, 16, 40], fill=(128, 128, 128))  # Shield

    elif unit_type == "knight":
        # Armored person
        draw.ellipse([14, 8, 34, 28], fill=(192, 192, 192))  # Helmet
        draw.rectangle([16, 28, 32, 44], fill=color)  # Armored body
        draw.rectangle([32, 20, 44, 38], fill=(160, 160, 160))  # Sword

    elif unit_type == "mage":
        # Person with staff
        draw.ellipse([14, 8, 34, 28], fill=color)  # Head
        draw.rectangle([18, 28, 30, 44], fill=color)  # Body/robe
        draw.line([34, 10, 34, 40], fill=(101, 67, 33), width=3)  # Staff
        draw.ellipse([32, 6, 36, 10], fill=(0, 191, 255))  # Magic orb

    elif unit_type == "archer":
        # Person with bow
        draw.ellipse([14, 8, 34, 28], fill=color)  # Head
        draw.rectangle([18, 28, 30, 44], fill=color)  # Body
        draw.arc([34, 18, 44, 38], 270, 90, fill=(101, 67, 33), width=2)  # Bow
        draw.line([39, 22, 39, 34], fill=(101, 67, 33), width=1)  # Bowstring

    # Add black outline
    draw.rectangle([0, 0, 47, 47], outline=(0, 0, 0), width=1)

    img.save(filename)
    print(f"Created {filename}")

# Generate tiles
create_tile("assets/sprites/tiles/grass.png", (34, 139, 34), pattern="solid")
create_tile("assets/sprites/tiles/forest.png", (34, 139, 34), (0, 100, 0), pattern="forest")
create_tile("assets/sprites/tiles/stone.png", (128, 128, 128), (96, 96, 96), pattern="stone")
create_tile("assets/sprites/tiles/gold.png", (139, 90, 0), (255, 215, 0), pattern="gold")

# Generate units with distinct colors
create_unit("assets/sprites/units/worker.png", (210, 180, 140), "worker")  # Tan
create_unit("assets/sprites/units/soldier.png", (178, 34, 34), "soldier")  # Red
create_unit("assets/sprites/units/knight.png", (70, 130, 180), "knight")  # Steel blue
create_unit("assets/sprites/units/mage.png", (138, 43, 226), "mage")  # Purple
create_unit("assets/sprites/units/archer.png", (34, 139, 34), "archer")  # Green

print("\nAll sprites generated successfully!")
print("Note: These are placeholder sprites and should be replaced with proper art assets later.")
