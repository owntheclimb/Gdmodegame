#!/usr/bin/env python3
"""Generate terrain tileset for the settlement game"""
from PIL import Image, ImageDraw
import os
import random

os.makedirs("assets/tilesets", exist_ok=True)

TILE_SIZE = 16

def add_noise(draw, x, y, base_color, variance=20):
    """Add subtle color variation"""
    r, g, b = base_color
    r = max(0, min(255, r + random.randint(-variance, variance)))
    g = max(0, min(255, g + random.randint(-variance, variance)))
    b = max(0, min(255, b + random.randint(-variance, variance)))
    return (r, g, b, 255)

def create_grass_tile():
    """Create a lush grass tile"""
    img = Image.new('RGBA', (TILE_SIZE, TILE_SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Base grass color
    base = (76, 153, 76)
    for y in range(TILE_SIZE):
        for x in range(TILE_SIZE):
            color = add_noise(draw, x, y, base, 15)
            draw.point((x, y), fill=color)
    
    # Add grass blades
    for _ in range(6):
        x = random.randint(0, TILE_SIZE-1)
        y = random.randint(0, TILE_SIZE-1)
        draw.point((x, y), fill=(50, 180, 50, 255))
    
    return img

def create_water_tile():
    """Create a water tile"""
    img = Image.new('RGBA', (TILE_SIZE, TILE_SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    base = (64, 164, 223)
    for y in range(TILE_SIZE):
        for x in range(TILE_SIZE):
            # Wave pattern
            wave = ((x + y) % 4 == 0)
            if wave:
                color = (100, 180, 240, 255)
            else:
                color = add_noise(draw, x, y, base, 10)
            draw.point((x, y), fill=color)
    
    return img

def create_sand_tile():
    """Create a beach/sand tile"""
    img = Image.new('RGBA', (TILE_SIZE, TILE_SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    base = (220, 200, 150)
    for y in range(TILE_SIZE):
        for x in range(TILE_SIZE):
            color = add_noise(draw, x, y, base, 12)
            draw.point((x, y), fill=color)
    
    # Add some pebbles
    for _ in range(3):
        x = random.randint(1, TILE_SIZE-2)
        y = random.randint(1, TILE_SIZE-2)
        draw.point((x, y), fill=(180, 160, 120, 255))
    
    return img

def create_forest_tile():
    """Create a darker forest floor tile"""
    img = Image.new('RGBA', (TILE_SIZE, TILE_SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    base = (45, 100, 45)
    for y in range(TILE_SIZE):
        for x in range(TILE_SIZE):
            color = add_noise(draw, x, y, base, 10)
            draw.point((x, y), fill=color)
    
    # Add leaves/debris
    for _ in range(4):
        x = random.randint(0, TILE_SIZE-1)
        y = random.randint(0, TILE_SIZE-1)
        draw.point((x, y), fill=(80, 60, 40, 255))
    
    return img

def create_mountain_tile():
    """Create a rocky mountain tile"""
    img = Image.new('RGBA', (TILE_SIZE, TILE_SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    base = (120, 120, 130)
    for y in range(TILE_SIZE):
        for x in range(TILE_SIZE):
            color = add_noise(draw, x, y, base, 20)
            draw.point((x, y), fill=color)
    
    # Add rocky texture
    for _ in range(5):
        x = random.randint(0, TILE_SIZE-2)
        y = random.randint(0, TILE_SIZE-2)
        shade = random.choice([90, 100, 140, 150])
        draw.point((x, y), fill=(shade, shade, shade+10, 255))
    
    return img

def create_tileset():
    """Create a complete tileset image"""
    # 5 tiles in a row, ordered: Water(0), Sand(1), Grass(2), Forest(3), Mountain(4)
    tileset = Image.new('RGBA', (TILE_SIZE * 5, TILE_SIZE), (0, 0, 0, 0))
    
    random.seed(42)  # Consistent randomness
    
    tiles = [
        create_water_tile(),     # Index 0 - TILE_WATER
        create_sand_tile(),      # Index 1 - TILE_SAND
        create_grass_tile(),     # Index 2 - TILE_GRASS
        create_forest_tile(),    # Index 3 - TILE_FOREST
        create_mountain_tile()   # Index 4 - TILE_MOUNTAIN
    ]
    
    for i, tile in enumerate(tiles):
        tileset.paste(tile, (i * TILE_SIZE, 0))
    
    tileset.save("assets/tilesets/terrain.png")
    print("Created terrain.png tileset")

if __name__ == "__main__":
    create_tileset()
    print("Tileset generated successfully!")
