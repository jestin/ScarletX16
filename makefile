ALL_ASM = $(wildcard src/*.asm) $(wildcard src/*.inc) $(wildcard src/*/*.asm) $(wildcard src/*/*.inc)
ALL_C = src/main.c
ALL_OBJS = $(patsubst %.c,%.o,$(wildcard src/*.c)) $(patsubst %.asm,%.obj,$(wildcard src/*.asm)) $(patsubst %.c,%.o,$(wildcard src/*/*.c)) $(patsubst %.asm,%.obj,$(wildcard src/*/*.asm))

ifdef OS
	RM = del /Q
	FixPath = $(subst /,\,$1)
else
	RM = rm -f
	FixPath = $1
endif

all: $(ALL_OBJS)
	cl65 -t cx16 -Osir -Cl -C src/cx16-bank.cfg -o export/SCARLET.PRG $(ALL_OBJS)

%.o: %.c
	cc65 -O -t cx16 -o $(patsubst %.o,%.s,$@) $<
	ca65 -t cx16  -o $@ $(patsubst %.o,%.s,$@)

%.obj: %.asm
	ca65 -t cx16 -o $@ $<

run:
	make
	x16emu -run -startin export -prg export/SCARLET.PRG -quality nearest -scale 2 -debug

debug:
	make
	box16 -run -hypercall_path export -prg SCARLET.PRG -quality nearest -scale 2

clean:
	$(RM) $(call FixPath, $(CURDIR)/src/*.s)
	$(RM) $(call FixPath, $(CURDIR)/src/*.o)
	$(RM) $(call FixPath, $(CURDIR)/src/*.obj)
	$(RM) $(call FixPath, $(CURDIR)/src/*.list)

	$(RM) $(call FixPath, $(CURDIR)/src/sprite_tools/*.s)
	$(RM) $(call FixPath, $(CURDIR)/src/sprite_tools/*.o)
	$(RM) $(call FixPath, $(CURDIR)/src/sprite_tools/*.obj)
	$(RM) $(call FixPath, $(CURDIR)/src/sprite_tools/*.list)

	$(RM) $(call FixPath, $(CURDIR)/export/SCARLET.PRG*)

# 	$(RM) $(call FixPath, $(CURDIR)/export/*.prg.*)
# 	$(RM) $(call FixPath, $(CURDIR)/export/*.spr)
# 	$(RM) $(call FixPath, $(CURDIR)/export/*.frm)
# 	$(RM) $(call FixPath, $(CURDIR)/export/*.tim)
# 	$(RM) $(call FixPath, $(CURDIR)/export/*.pal)
# 	$(RM) $(call FixPath, $(CURDIR)/export/*.tset)
# 	$(RM) $(call FixPath, $(CURDIR)/export/*.tmap)
