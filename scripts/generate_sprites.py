#!/usr/bin/env python3
"""Generate cute pixel art sprites for the settlement game"""
from PIL import Image, ImageDraw
import os

# Ensure assets directory exists
os.makedirs("assets/sprites", exist_ok=True)

def create_villager():
    """Create a cute 16x16 villager sprite"""
    img = Image.new('RGBA', (16, 16), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Body (tunic) - warm brown
    draw.rectangle([5, 7, 10, 12], fill=(139, 90, 43, 255))
    
    # Head (skin tone)
    draw.rectangle([5, 3, 10, 7], fill=(255, 213, 170, 255))
    
    # Hair (brown)
    draw.rectangle([5, 2, 10, 4], fill=(101, 67, 33, 255))
    
    # Eyes
    draw.point((6, 5), fill=(50, 50, 50, 255))
    draw.point((9, 5), fill=(50, 50, 50, 255))
    
    # Legs
    draw.rectangle([5, 12, 7, 15], fill=(60, 60, 80, 255))
    draw.rectangle([8, 12, 10, 15], fill=(60, 60, 80, 255))
    
    # Arms
    draw.rectangle([3, 8, 5, 11], fill=(255, 213, 170, 255))
    draw.rectangle([10, 8, 12, 11], fill=(255, 213, 170, 255))
    
    img.save("assets/sprites/villager.png")
    print("Created villager.png")

def create_tree():
    """Create a nice 24x32 tree sprite"""
    img = Image.new('RGBA', (24, 32), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Trunk (brown)
    draw.rectangle([10, 20, 14, 31], fill=(101, 67, 33, 255))
    draw.rectangle([9, 22, 15, 30], fill=(139, 90, 43, 255))
    
    # Foliage layers (various greens) - triangular shape
    # Bottom layer
    draw.ellipse([2, 12, 22, 26], fill=(34, 139, 34, 255))
    # Middle layer
    draw.ellipse([4, 6, 20, 20], fill=(50, 160, 50, 255))
    # Top layer
    draw.ellipse([6, 1, 18, 14], fill=(60, 179, 60, 255))
    # Highlights
    draw.ellipse([8, 4, 14, 10], fill=(80, 200, 80, 255))
    
    img.save("assets/sprites/tree.png")
    print("Created tree.png")

def create_rock():
    """Create a 16x12 rock sprite"""
    img = Image.new('RGBA', (16, 12), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Main rock body (gray)
    draw.ellipse([1, 2, 15, 11], fill=(128, 128, 128, 255))
    
    # Darker shadow
    draw.ellipse([2, 4, 14, 11], fill=(100, 100, 100, 255))
    
    # Highlight
    draw.ellipse([3, 2, 10, 7], fill=(160, 160, 160, 255))
    draw.ellipse([4, 3, 8, 5], fill=(180, 180, 180, 255))
    
    img.save("assets/sprites/rock.png")
    print("Created rock.png")

def create_berry_bush():
    """Create a 20x16 berry bush sprite"""
    img = Image.new('RGBA', (20, 16), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Bush foliage (green)
    draw.ellipse([1, 4, 19, 15], fill=(34, 120, 34, 255))
    draw.ellipse([3, 2, 17, 13], fill=(50, 140, 50, 255))
    
    # Berries (red/pink)
    berry_positions = [(4, 6), (8, 4), (12, 5), (15, 7), (6, 10), (10, 9), (14, 11)]
    for x, y in berry_positions:
        draw.ellipse([x, y, x+3, y+3], fill=(220, 50, 80, 255))
        draw.point((x+1, y), fill=(255, 150, 150, 255))  # highlight
    
    img.save("assets/sprites/berry_bush.png")
    print("Created berry_bush.png")

def create_building_hut():
    """Create a 32x32 hut/building sprite"""
    img = Image.new('RGBA', (32, 32), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Roof (straw/thatch color)
    points = [(16, 2), (2, 14), (30, 14)]
    draw.polygon(points, fill=(180, 140, 80, 255))
    # Roof shadow
    points2 = [(16, 5), (5, 14), (27, 14)]
    draw.polygon(points2, fill=(160, 120, 60, 255))
    
    # Walls (wood/clay)
    draw.rectangle([4, 14, 28, 30], fill=(160, 120, 80, 255))
    draw.rectangle([6, 14, 26, 30], fill=(180, 140, 100, 255))
    
    # Door
    draw.rectangle([13, 20, 19, 30], fill=(101, 67, 33, 255))
    draw.rectangle([14, 21, 18, 30], fill=(80, 50, 25, 255))
    
    # Window
    draw.rectangle([22, 18, 26, 24], fill=(135, 206, 235, 255))
    draw.line([(22, 21), (26, 21)], fill=(101, 67, 33, 255))
    draw.line([(24, 18), (24, 24)], fill=(101, 67, 33, 255))
    
    img.save("assets/sprites/hut.png")
    print("Created hut.png")

def create_creature():
    """Create a 16x16 deer/animal sprite"""
    img = Image.new('RGBA', (16, 16), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Body (brown)
    draw.ellipse([3, 6, 13, 13], fill=(180, 130, 80, 255))
    
    # Head
    draw.ellipse([10, 3, 15, 9], fill=(180, 130, 80, 255))
    
    # Legs
    draw.rectangle([4, 12, 6, 15], fill=(150, 100, 60, 255))
    draw.rectangle([10, 12, 12, 15], fill=(150, 100, 60, 255))
    
    # Eye
    draw.point((13, 5), fill=(0, 0, 0, 255))
    
    # Ear
    draw.polygon([(12, 2), (14, 1), (14, 4)], fill=(180, 130, 80, 255))
    
    # Tail
    draw.ellipse([1, 7, 4, 10], fill=(200, 150, 100, 255))
    
    img.save("assets/sprites/creature.png")
    print("Created creature.png")

def create_construction_site():
    """Create a 32x32 construction site sprite"""
    img = Image.new('RGBA', (32, 32), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Foundation
    draw.rectangle([2, 24, 30, 30], fill=(139, 119, 101, 255))
    
    # Wooden frame posts
    draw.rectangle([4, 8, 7, 24], fill=(160, 120, 80, 255))
    draw.rectangle([25, 8, 28, 24], fill=(160, 120, 80, 255))
    
    # Horizontal beam
    draw.rectangle([4, 8, 28, 11], fill=(180, 140, 100, 255))
    
    # Scaffolding
    draw.line([(7, 8), (25, 24)], fill=(120, 80, 40, 255), width=2)
    draw.line([(7, 24), (25, 8)], fill=(120, 80, 40, 255), width=2)
    
    img.save("assets/sprites/construction_site.png")
    print("Created construction_site.png")

def create_storage():
    """Create a 28x24 storage/chest sprite"""
    img = Image.new('RGBA', (28, 24), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Main chest body
    draw.rectangle([2, 8, 26, 22], fill=(139, 90, 43, 255))
    draw.rectangle([4, 10, 24, 22], fill=(160, 110, 60, 255))
    
    # Lid
    draw.rectangle([2, 4, 26, 10], fill=(120, 80, 40, 255))
    draw.rectangle([4, 6, 24, 10], fill=(139, 90, 43, 255))
    
    # Metal bands
    draw.rectangle([2, 8, 26, 10], fill=(80, 80, 80, 255))
    draw.rectangle([12, 4, 16, 22], fill=(100, 100, 100, 255))
    
    # Lock
    draw.rectangle([12, 10, 16, 14], fill=(200, 170, 50, 255))
    
    img.save("assets/sprites/storage.png")
    print("Created storage.png")

def create_event_marker():
    """Create a 16x24 event marker (exclamation/question mark)"""
    img = Image.new('RGBA', (16, 24), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Glowing background
    draw.ellipse([2, 2, 14, 22], fill=(255, 220, 100, 100))
    
    # Exclamation mark
    draw.rectangle([6, 4, 10, 14], fill=(255, 200, 50, 255))
    draw.ellipse([6, 17, 10, 21], fill=(255, 200, 50, 255))
    
    img.save("assets/sprites/event_marker.png")
    print("Created event_marker.png")

# Generate all sprites
if __name__ == "__main__":
    create_villager()
    create_tree()
    create_rock()
    create_berry_bush()
    create_building_hut()
    create_creature()
    create_construction_site()
    create_storage()
    create_event_marker()
    print("\n✨ All sprites generated successfully!")
