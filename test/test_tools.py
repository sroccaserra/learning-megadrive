from tools.convertImage import to_hex_string, to_binary_data


class TestTools:
    def test_converting_int_indices_to_hex_string(self):
        indices = [0, 1, 10, 15]
        hex_nibbles = to_hex_string(indices)
        assert hex_nibbles == '01AF'

    def test_converting_4_bytes_indices_to_bin(self):
        indices = [0, 1, 10, 15]
        binary_data = to_binary_data(indices)
        assert binary_data == b'\x01\xaf'
