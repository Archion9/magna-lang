god := odin
gxx := gcc

build:
	$(god) build .

run:
	.\magna-lang.exe -build
	$(gxx) -x assembler test.asm
	.\a.exe

clean:
	@del .\*.asm .\*.exe
.PHONY: clean