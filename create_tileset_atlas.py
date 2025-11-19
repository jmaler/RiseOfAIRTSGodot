#!/usr/bin/env python3
"""
Create a tileset atlas combining all tile sprites into one image.
This makes it easier to use in Godot's TileMap.
"""

from PIL import Image
import os

# Load individual tiles
tiles_dir = "assets/sprites/tiles"
tile_files = ["grass.png", "forest.png", "stone.png", "gold.png"]

# Create atlas (4 tiles horizontally, 64x64 each = 256x64)
atlas = Image.new('RGBA', (256, 64), (0, 0, 0, 0))

for i, tile_file in enumerate(tile_files):
    tile_path = os.path.join(tiles_dir, tile_file)
    if os.path.exists(tile_path):
        tile_img = Image.open(tile_path)
        atlas.paste(tile_img, (i * 64, 0))
        print(f"Added {tile_file} at position {i}")

# Save atlas
atlas_path = "assets/sprites/tiles/tileset_atlas.png"
atlas.save(atlas_path)
print(f"\nTileset atlas created: {atlas_path}")
print("Atlas contains: Grass(0), Forest(1), Stone(2), Gold(3)")
