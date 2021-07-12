from PIL import Image
import sys
from os import path
import xml.etree.ElementTree as ElTree

def update_pixel(p, max_foliage_index):
    # Get combined red (p[0]) and green p[1] values as combined 16 bit value [8 bits green, 8 bits red]
    channel = p[0] + (256 * p[1])
    # First 5 red bits are crop ID, little-endian, representing 0-31
    index = channel % 32
    # Invalid pixels set to black (where foliage channel unused in map
    if index > max_foliage_index:
        return (0,0,0)
    # Next 5 bits are crop growth stage (last 3 red bits + first 2 green)
    state = channel // 32
    # Multiply state by 64 (6 bit offset) to leave a 6 bit window for crop indices
    new_channel = (state * 64) + index
    # Recombine value into 8 red bits (lower values), 8 green bits (higher values), and blue (unused)
    return (new_channel % 256, new_channel // 256, 0)

def usage():
    print("Map directory or modDesc.xml file path required as first argument\n")
    print("Try dragging your map's modDesc.xml onto fruit_density_converter.exe\n")
    print("Press any key to continue...")
    input()
    exit()

# Get the map's base directory from command line arguments
try:
    map_path = sys.argv[1]
    if path.isdir(map_path):
        map_dir = map_path
    else:
        map_dir = path.dirname(map_path)
except IndexError:
    usage()

try:
    # Inspecting the map. First we get the modDesc.xml
    mod_desc_path = path.join(map_dir, 'modDesc.xml')
    print(f"Parsing modDesc at {mod_desc_path}")
    mod_desc = ElTree.parse(mod_desc_path)
    # Get the map's XML path from the modDesc.xml
    map_xml_path = path.join(map_dir, mod_desc.getroot().find('maps').find('map').attrib["configFilename"])
    print(f"Parsing map config XML at {map_xml_path}")
    map_xml = ElTree.parse(map_xml_path)
    # Get the map's i3d path from the config XML
    map_i3d_path = path.join(map_dir, map_xml.getroot().find('filename').text)
    print(f"Parsing map i3d file at {map_i3d_path}")
    map_i3d = ElTree.parse(map_i3d_path)
    # Count the number of foliage types in the map so we can identify invalid pixels
    foliage_type_count = len(map_i3d.getroot().find(
        "./Scene/TerrainTransformGroup/Layers/FoliageMultiLayer"
        ).findall("FoliageType"))
    print(f"Number of foliage indices used: {foliage_type_count}")
    # Find the fruit_density file path from the i3d File listings
    for file_entry in map_i3d.getroot().findall("./Files/File"):
        filename = file_entry.get("filename", "")
        if filename.endswith("fruit_density.gdm") or filename.endswith("fruit_density.png"):
            fruit_density_path = path.join(path.dirname(path.join(path.dirname(map_i3d_path), filename)), "fruit_density.png")
            break
except ElTree.ParseError:
    usage()

print(f"Processing fruit_density PNG at {fruit_density_path}")
img = Image.open(fruit_density_path)
list_of_pixels = list(img.getdata())
new_list_of_pixels = [update_pixel(p, (foliage_type_count - 1)) for p in list_of_pixels]
img.putdata(new_list_of_pixels)
converted_img_path = path.join(path.dirname(fruit_density_path), "fruit_density_new.png")
img.save(converted_img_path)
print(f"Saved new image at: {converted_img_path}")
print("Press any key to continue...")
input()
