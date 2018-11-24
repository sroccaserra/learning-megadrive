Learning how to display Mega Drive graphics in 68000 assembly.

I use the m68k [vasm assembler](http://sun.hasenbraten.de/vasm/index.php?view=main) with Motorola syntax, and the Mega Drive startup kit from the awesome [Gamehut](https://www.youtube.com/channel/UCfVFSjHQ57zyxajhhRc7i0g) Youtube channel.

<img src="doc/Screenshot.png" width="435px" height="auto">

## Prerequisites

Download the vasm tarball and build `vasmm68k_mot` with these options from [the compilation instructions](http://sun.hasenbraten.de/vasm/index.php?view=compile):

    make CPU=m68k SYNTAX=mot

Now you need to have the `vasmm68k_mot` executable in your path somehow, see how it's done depending on your OS / shell.

## Build the rom.bin file

To build the `bin/rom.bin` file from the assembly source code, run:

    make

## Run the rom.bin file

Open the generated `bin/rom.bin` file in your favourite Mega Drive emulator, it should display a scrolling checkboard :)

There is a `run` target in the Makefile, but it won't work for you unless you override the `EMULATOR_PATH`, `EMULATOR_CMD`, and `ROM_PATH` env variables. Chances are you don't have the same emulator installed in the exact same path as I do :)

## Tools

To include the graphics in the cartridge ROM, it's easier to have the corresponding index and palette data in a binary format ready to inject in the Mega Drive VDP (Video Display Processor).

But I wanted to be able to edit the graphic assets with standard tools like GIMP, so the assets are images in indexed PNG format.

So I needed tools to extract the index and palette data from the PNG indexed images, and convert them to the right VDP binary formats. The VDP needs raw 8x8 nibble tiles representing indexes for graphics, each index points to a color in a 16 colors palette. And a 16 color palette is represented by 16 words, each word represents a color and is arranged in this order: `0000 bbb0 ggg0 rrr0`. (This means that there are 3 bits per color component, so a palette is a 16 color set within a total of `2^3*2^3*2^3 = 512` possible colors.)

That's what the Python scripts in the `tools/` directory do, they convert the index and palette data (16 first colors only) from the PNG images to binary formats ready to include in the cartridge rom. I used the `.gfx` and `.pal` extensions for the binary formats representing these data. The `.gfx` and `.pal` files are generated in the `bin` directory, they are not included in the source code.

See the `Makefile` and Python scripts & tests for more details.

## Todo

Maybe:
- Complete part 3 of GameHut tutorial
- Add tiled font and try drawing text
- Add support for 24bpp PNG files for PNG assets, build color palette as new colors are found (exception if > 16?)
- Check that asset width & heigth are multiples of 8
- Add info about assets dimentions in file names (so it's easier to remember while reading assembly code including them)

## References

- The three parts tutorial by Jon Burton, see the [doc/Gamehut](doc/Gamehut) directory and the [How to Code!][htc] videos
- vasm assembler: <http://sun.hasenbraten.de/vasm/index.php?view=main>
    - [vasm docs](http://sun.hasenbraten.de/vasm/release/vasm.html)
    - [Mot Syntax Module](http://sun.hasenbraten.de/vasm/release/vasm_4.html)
- 68000 instructions tutorial: <http://mrjester.hapisan.com/04_MC68/Index.html>
- Another Mega Drive tutorial: <https://huguesjohnson.com/programming/genesis/palettes/>
- Lots of Mega Drive dev info: <https://plutiedev.com/>
- <https://darkdust.net/writings/megadrive>
- Sega Genesis/Mega Drive VDP Graphics Guide: <https://megacatstudios.com/blogs/press/sega-genesis-mega-drive-vdp-graphics-guide-v1-2a-03-14-17>

[htc]: https://www.youtube.com/playlist?list=PLi29TNPrdbwLmUjiVvLLrRky7cXrlSIYr
