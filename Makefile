build:
	@mkdir -p bin
	@vasmm68k_mot -o bin/learn.bin -Fbin -no-opt -nosym -chklabels src/main.asm

clean:
	@rm bin/*.bin
