from PIL import Image
import sys
from os import path

def update_pixel(p):
    channel = p[0] + (256 * p[1])
    state = channel // 32
    index = channel % 32
    new_channel = (state * 64) + index
    return (new_channel % 256, new_channel // 256, 0)

img_filepath = sys.argv[1]
img = Image.open(img_filepath)
print(f"Processing {img_filepath}")
list_of_pixels = list(img.getdata())
new_list_of_pixels = list(map(update_pixel, list_of_pixels))
img.putdata(new_list_of_pixels)
converted_img_path = path.join(path.dirname(img_filepath), "fruit_density_new.png")
img.save(converted_img_path)
print(f"Saved new image at: {converted_img_path}")
print("Press any key to continue...")
input()
