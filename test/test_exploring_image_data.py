from PIL import Image


class TestExploringImageData:
    def test_loading_indices(self):
        im = Image.open('test/test.png')
        indices = list(im.getdata())
        assert indices == [0, 1, 2, 3]
