Learning how to display Mega Drive graphics in 68000 assembly.

I use the m68k [vasm assembler](http://sun.hasenbraten.de/vasm/index.php?view=main) with Motorola syntax, and the Mega Drive startup kit from the awesome [Gamehut](https://www.youtube.com/channel/UCfVFSjHQ57zyxajhhRc7i0g) Youtube channel.

## Prerequisites

Download the vasm tarball and build `vasmm68k_mot` with these options from [the compilation instructions](http://sun.hasenbraten.de/vasm/index.php?view=compile):

    make CPU=m68k SYNTAX=mot

## Build the .bin file

To build tne `bin/learn.bin` file from the assembly source code, run:

    make build

## Run the .bin file

Open the generated `bin/learn.bin` file in your favourite Mega Drive emulator, it should display a scrolling checkboard :)

## References

- vasm assembler: <http://sun.hasenbraten.de/vasm/index.php?view=main>
- Startup kit: <https://www.youtube.com/watch?v=PSYhSmXBgIw>
- Tutorial: <https://huguesjohnson.com/programming/genesis/palettes/>
