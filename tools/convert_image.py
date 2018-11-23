import binascii
import sys

from PIL import Image


def to_hex_string(indices):
    return ''.join(['%X' % i for i in indices])


def to_binary_data(indices):
    hex_string = to_hex_string(indices)
    return binascii.unhexlify(hex_string)


def main():
    image_file_name = sys.argv[1]
    output_file_name = sys.argv[2]

    im = Image.open(image_file_name)
    indices = list(im.getdata())

    byte_data = to_binary_data(indices)

    with open(output_file_name, 'wb') as output_file:
        output_file.write(byte_data)


if __name__ == "__main__":
    main()
