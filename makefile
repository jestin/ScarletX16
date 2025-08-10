ALL_ASM = $(wildcard src/*.asm) $(wildcard src/*.inc)
ALL_C = src/main.c
ALL_OBJS = $(patsubst %.c,%.o,$(wildcard src/*.c)) $(patsubst %.asm,%.obj,$(wildcard src/*.asm))

all: $(ALL_OBJS)
	cl65 -t cx16 -Osir -Cl -C src/cx16-bank.cfg -o export/SCARLET.PRG $(ALL_OBJS)

%.o: %.c
	cc65 -O -t cx16 -o $(patsubst %.o,%.s,$@) $<
	ca65 -t cx16  -o $@ $(patsubst %.o,%.s,$@)

%.obj: %.asm
	ca65 -t cx16 -o $@ $<

run:
	make
	x16emu -run -startin export -prg export/SCARLET.PRG -quality nearest -scale 1 -debug

debug:
	make
	box16 -run -hypercall_path export -prg SCARLET.PRG -quality nearest -scale 2

clean:
	del $(subst /,\, $(CURDIR)\src\*.s)
	del $(subst /,\, $(CURDIR)\src\*.o)
	del $(subst /,\, $(CURDIR)\src\*.obj)
	del $(subst /,\, $(CURDIR)\src\*.list)

# 	del $(subst /,\, $(CURDIR)\export\*.prg.*)
# 	del $(subst /,\, $(CURDIR)\export\*.spr)
# 	del $(subst /,\, $(CURDIR)\export\*.frm)
# 	del $(subst /,\, $(CURDIR)\export\*.tim)
# 	del $(subst /,\, $(CURDIR)\export\*.pal)
# 	del $(subst /,\, $(CURDIR)\export\*.tset)
# 	del $(subst /,\, $(CURDIR)\export\*.tmap)