import json
import colorsys
import random

random.seed(42)

CATEGORY_OBJECTS = {
    "reds": ["ripe cherries", "a fresh rose", "brick walls"],
    "oranges": ["autumn leaves", "a glowing sunset", "tangerine peel"],
    "yellows": ["sunflower petals", "ripe lemons", "morning sunlight"],
    "greens": ["spring grass", "pine forests", "fresh herbs"],
    "blues": ["clear skies", "deep ocean water", "a twilight horizon"],
    "purples": ["violet blossoms", "royal velvet", "lavender fields"],
    "neutrals": ["weathered stone", "soft ash", "driftwood"],
}

TEMPLATES = [
    "A {sat_adj} {light_adj} {cat} reminiscent of {obj}.",
    "This {cat} evokes {obj} with its {sat_adj} {light_adj} tone.",
    "Similar to {obj}, it's a {sat_adj} {light_adj} {cat}.",
    "Named after {obj}, this {cat} has a {sat_adj} {light_adj} look.",
]


def hsl_from_hex(hex_color):
    hex_color = hex_color.lstrip('#')
    r = int(hex_color[0:2], 16) / 255.0
    g = int(hex_color[2:4], 16) / 255.0
    b = int(hex_color[4:6], 16) / 255.0
    return colorsys.rgb_to_hls(r, g, b)


def adjectives(hex_color):
    h, l, s = hsl_from_hex(hex_color)
    if l < 0.3:
        light_adj = "dark"
    elif l < 0.6:
        light_adj = "medium"
    else:
        light_adj = "light"

    if s < 0.3:
        sat_adj = "muted"
    elif s < 0.6:
        sat_adj = "soft"
    else:
        sat_adj = "vibrant"
    return light_adj, sat_adj


def choose_object(name, category):
    lower = name.lower()
    keywords = {
        "navy": "naval uniforms",
        "banana": "ripe bananas",
        "fire": "flames",
        "mint": "mint leaves",
        "peach": "fresh peaches",
        "rose": "rose petals",
        "sky": "a clear sky",
        "chocolate": "chocolate bars",
        "coffee": "fresh coffee",
        "sea": "the open sea",
        "olive": "olive groves",
        "lavender": "lavender blossoms",
    }
    for k, v in keywords.items():
        if k in lower:
            return v
    return random.choice(CATEGORY_OBJECTS.get(category, CATEGORY_OBJECTS["neutrals"]))


def generate_description(name, hex_color, category):
    light_adj, sat_adj = adjectives(hex_color)
    obj = choose_object(name, category)
    template = random.choice(TEMPLATES)
    cat_word = category.rstrip('s')  # remove plural
    return template.format(sat_adj=sat_adj, light_adj=light_adj, cat=cat_word, obj=obj)


def main():
    with open('HueKnew/Data/colors.json') as f:
        data = json.load(f)

    for color in data['colors']:
        color['description'] = generate_description(color['name'], color['hex'], color['category'])

    with open('HueKnew/Data/colors.json', 'w') as f:
        json.dump(data, f, indent=2)
        f.write('\n')

if __name__ == '__main__':
    main()
