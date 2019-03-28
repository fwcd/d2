import sys
from PIL import Image

if len(sys.argv) < 3:
    print("Syntax: [new width] [new height] [images files...]")
else:
    new_width = int(sys.argv[1])
    new_height = int(sys.argv[2])
    
    for image_file in sys.argv[3:]:
        try:
            image = Image.open(image_file)
            image.thumbnail((new_width, new_height), Image.ANTIALIAS)
            image.save(image_file, "PNG")
        except IOError:
            print(f"IOError while processing {image_file}")
