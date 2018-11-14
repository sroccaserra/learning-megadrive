ASM_FILES := $(wildcard src/*.asm)
HEX_DATA := $(wildcard data/*.hex)
BIN_DATA = $(HEX_DATA:data/%.hex=bin/%.bin)
GRAPHICS_SOURCE := $(wildcard data/*.xpm2)
GRAPHICS_DATA = $(GRAPHICS_SOURCE:data/%.xpm2=bin/%.dat)

REMOVE_COMMENTS = sed 's/;.*$$//g'
REMOVE_WHITESPACES = tr -d ' \t\n\r\f'
CONVERT_TO_BIN = xxd -r -p -

REMOVE_XPM2_HEADER = tail -n +19

EMULATOR_PATH ?= /Users/sebastien.roccaserra/Applications/Games/RetroArch.app/Contents/Macos
EMULATOR_CMD ?= ./RetroArch -L
ROM_PATH ?= ../Resources/cores/picodrive_libretro.dylib /Users/sebastien.roccaserra/Developer/learn-mega-drive/bin/rom.bin

bin/rom.bin: $(BIN_DATA) $(ASM_FILES) $(GRAPHICS_DATA)
	vasmm68k_mot -o bin/rom.bin -Fbin -no-opt -nosym -chklabels src/main.asm

bin/%.bin: data/%.hex
	@mkdir -p bin
	$(REMOVE_COMMENTS) $< \
		| $(REMOVE_WHITESPACES) \
		| $(CONVERT_TO_BIN) $@

bin/%.dat: data/%.xpm2
	$(REMOVE_XPM2_HEADER) $< \
		| $(REMOVE_WHITESPACES) \
		| $(CONVERT_TO_BIN) $@


run: bin/rom.bin
	cd $(EMULATOR_PATH) && $(EMULATOR_CMD) $(ROM_PATH)

clean:
	rm bin/*.bin bin/*.dat
