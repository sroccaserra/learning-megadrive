from tools.convert_image import to_hex_string, to_binary_data
from tools.convert_palette import convert_8bpc_to_3bpc, \
                                  convert_8bpc_to_shifted_nibble, \
                                  convert_24_bit_color_for_VDP, \
                                  group_colors, \
                                  convert_palette_to_hex


class TestConvertingIndexedData:
    def test_converting_int_indices_to_hex_string(self):
        indices = [0, 1, 10, 15]
        hex_nibbles = to_hex_string(indices)
        assert hex_nibbles == '01AF'

    def test_converting_4_bytes_indices_to_bin(self):
        indices = [0, 1, 10, 15]
        binary_data = to_binary_data(indices)
        assert binary_data == b'\x01\xaf'


class TestConvertingPaletteData:
    def test_converting_8bpc_to_3bpc(self):
        assert convert_8bpc_to_3bpc(0) == 0
        assert convert_8bpc_to_3bpc(18) == 0
        assert convert_8bpc_to_3bpc(19) == 1
        assert convert_8bpc_to_3bpc(236) == 6
        assert convert_8bpc_to_3bpc(237) == 7
        assert convert_8bpc_to_3bpc(255) == 7

    def test_converting_8pbb_to_shifted_nibble(self):
        assert convert_8bpc_to_shifted_nibble(0) == '0'
        assert convert_8bpc_to_shifted_nibble(18) == '0'
        assert convert_8bpc_to_shifted_nibble(19) == '2'
        assert convert_8bpc_to_shifted_nibble(236) == 'C'
        assert convert_8bpc_to_shifted_nibble(237) == 'E'
        assert convert_8bpc_to_shifted_nibble(255) == 'E'

    def test_converting_24bpc_to_VDP_color_data(self):
        assert convert_24_bit_color_for_VDP([0, 0, 0]) == '0000'
        assert convert_24_bit_color_for_VDP([255, 0, 0]) == '000E'
        assert convert_24_bit_color_for_VDP([0, 255, 0]) == '00E0'
        assert convert_24_bit_color_for_VDP([0, 0, 255]) == '0E00'
        assert convert_24_bit_color_for_VDP([255, 255, 255]) == '0EEE'

    def test_grouping_palette_colors(self):
        assert group_colors([24, 20, 12, 244, 240, 232]) == [(24, 20, 12), (244, 240, 232)]

    def test_converting_palette_data_to_VDP_color_data(self):
        assert convert_palette_to_hex([24, 20, 12, 244, 240, 232]) == '00220CEE'
