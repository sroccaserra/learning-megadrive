ASM_FILES := $(wildcard src/*.asm)

HEX_DATA := $(wildcard data/*.hex)
BIN_DATA = $(HEX_DATA:data/%.hex=bin/%.dat)

GRAPHICS_SOURCE := $(wildcard data/*.png)
GRAPHICS_DATA = $(GRAPHICS_SOURCE:data/%.png=bin/%.gfx)
PALETTE_DATA = $(GRAPHICS_SOURCE:data/%.png=bin/%.pal)

REMOVE_COMMENTS = sed 's/;.*$$//g'
REMOVE_WHITESPACES = tr -d ' \t\n\r\f'
CONVERT_TO_BIN = xxd -r -p -

EMULATOR_PATH ?= /Users/sebastien.roccaserra/Applications/Games/RetroArch.app/Contents/Macos
EMULATOR_CMD ?= ./RetroArch -L ../Resources/cores/picodrive_libretro.dylib
ROM_PATH ?= /Users/sebastien.roccaserra/Developer/learning-megadrive/bin/rom.bin

bin/rom.bin: $(BIN_DATA) $(ASM_FILES) $(GRAPHICS_DATA) $(PALETTE_DATA)
	vasmm68k_mot -o bin/rom.bin -Fbin -no-opt -nosym -chklabels src/main.asm

bin/%.dat: data/%.hex
	@mkdir -p bin
	$(REMOVE_COMMENTS) $< \
		| $(REMOVE_WHITESPACES) \
		| $(CONVERT_TO_BIN) $@

bin/%.gfx: data/%.png requirements
	source venv/bin/activate; \
	python tools/convert_image.py $< $@

bin/%.pal: data/%.png requirements
	source venv/bin/activate; \
	python tools/convert_palette.py $< $@

run: bin/rom.bin
	cd $(EMULATOR_PATH) && \
		$(EMULATOR_CMD) $(ROM_PATH)

venv:
	virtualenv -p python3 venv

requirements: venv requirements.txt
	source venv/bin/activate; \
	pip install -r requirements.txt

python: venv
	source venv/bin/activate; \
	python --version

.PHONY: test
test:
	source venv/bin/activate; \
	pytest -vv test

clean:
	rm -f bin/rom.bin $(BIN_DATA) $(GRAPHICS_DATA) $(PALETTE_DATA)
