# The parts of the makefile that change with sketch follow:
PROJ_NAME=${sketch:name}
UECIDE_INSTALLATION="${uecide:jar}"
BOARD_NAME=${board:name}
DEVICE=PIC${build.mcu}
COMP=${compiler:root}
BOOTLOADER=${bootloader.file}.hex
#################### The rest of the makefile does not need to change ########################


# Command to recreate the .elf. Note that we issue --programmer=pickit2 so that the .elf will contain in the bootloader area a simple crt0 that jumps to 
# the application. So, the .elf will not contain the chipKIT bootloader
COMMAND_DEBUG=java -jar $(UECIDE_INSTALLATION) --force-save-hex --force-local-build --board=$(BOARD_NAME) --compile --headless --programmer=pickit2 .
# Command to recreate .hex. Note that we issue --programmer=avrdude so that the hex file will not contain any bootcode. Then we will merge the
# chipKIT bootloader with this .hex file
# the application. So, the .elf will not contain the chipKIT bootloader
COMMAND_PRODUCTION=java -jar $(UECIDE_INSTALLATION) --force-save-hex --force-local-build --board=$(BOARD_NAME) --compile --headless --programmer=avrdude .

# target (make production)
production: build/$(PROJ_NAME)_with_bootloader.hex

# target (make debug)
debug: build/$(PROJ_NAME).elf

# target (make clean)
clean:
	@rm -rf build

build/$(PROJ_NAME)_with_bootloader.hex: build/$(PROJ_NAME).hex
	head -n -1 $(BOOTLOADER) > build/$(PROJ_NAME)_with_bootloader.hex
	cat build/$(PROJ_NAME).hex  >> build/$(PROJ_NAME)_with_bootloader.hex

# User might modify the .cpp itself. So, let's add it as a prerequisite
# only if it exists
CPP_FILE=$(wildcard build/$(PROJ_NAME).cpp)
build/$(PROJ_NAME).hex: $(PROJ_NAME).ino $(CPP_FILE)
	$(COMMAND_PRODUCTION)
	rm -f build/$(PROJ_NAME).elf

build/$(PROJ_NAME).elf: $(PROJ_NAME).ino $(CPP_FILE)
	$(COMMAND_DEBUG)
	rm -f build/$(PROJ_NAME).hex
