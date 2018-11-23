import binascii
import sys
from itertools import zip_longest

from PIL import Image


def convert_8bpc_to_3bpc(n):
    return round(n*7/255)


def convert_8bpc_to_shifted_nibble(n):
    int_value = convert_8bpc_to_3bpc(n)
    return '%X' % (2*int_value)


def convert_24_bit_color_for_VDP(rgb_values):
    b = convert_8bpc_to_shifted_nibble(rgb_values[2])
    g = convert_8bpc_to_shifted_nibble(rgb_values[1])
    r = convert_8bpc_to_shifted_nibble(rgb_values[0])
    return '0'+b+g+r


def group_colors(palette_data):
    iterators = [iter(palette_data)] * 3
    return list(zip_longest(*iterators))


def convert_palette_to_hex(palette_data):
    grouped_colors = group_colors(palette_data)
    VDP_colors = [convert_24_bit_color_for_VDP(color)
                  for color in grouped_colors]
    return ''.join(VDP_colors)


def main():
    image_file_name = sys.argv[1]
    output_file_name = sys.argv[2]

    im = Image.open(image_file_name)
    sixteen_colors_palette_data = list(im.getpalette())[:3*16]

    hex_string = convert_palette_to_hex(sixteen_colors_palette_data)
    byte_data = binascii.unhexlify(hex_string)

    with open(output_file_name, 'wb') as output_file:
        output_file.write(byte_data)


if __name__ == "__main__":
    main()
