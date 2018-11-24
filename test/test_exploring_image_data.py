from PIL import Image


class TestExploringImageData:
    def setup_method(self):
        self.image = Image.open('test/test_indexed.png')

    def test_loading_indices(self):
        indices = list(self.image.getdata())
        assert indices == [0, 1, 2, 3]

    def test_extracting_palette(self):
        first_16_colors = self.image.getpalette()[:3*16]
        assert first_16_colors == [
                24, 20, 12,
                244, 240, 232,
                196, 68, 72,
                48, 132, 92,
                240, 232, 72,
                52, 48, 116,
                188, 48, 108,
                40, 116, 196,
                24, 20, 12,
                244, 240, 232,
                196, 68, 72,
                48, 132, 92,
                240, 232, 72,
                52, 48, 116,
                188, 48, 108,
                40, 116, 196
                ]
