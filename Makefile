

PYTHON=python3.10
PRUN= source ./venv/bin/activate && $(PYTHON)

LITEX_BOARDS=./litex/litex-boards/
TARGET=digilent_arty
#TARGET=xilinx_zybo_z7
#TARGET_OPTIONS= --toolchain openxc7 --cpu-type picorv32 --with-xadc
TARGET_OPTIONS= --cpu-type picorv32 --with-xadc

CHIPDB=/opt/chipdb
VIVADO_SETTINGS=/opt/Xilinx/Vivado/2017.2/settings64.sh
RISCV=/opt/riscv/bin/

venv:
	$(PYTHON) -m venv venv

alias_test:
	alias foo='echo this is foo' && \
		foo saying hello

test_env: venv
	$(PRUN) -V
	source ./venv/bin/activate && python -V

litex: venv
	source ./venv/bin/activate && python -V
	mkdir -p litex
	cd litex && \
		wget https://raw.githubusercontent.com/enjoy-digital/litex/master/litex_setup.py && \
		chmod +x litex_setup.py && \
		source ../venv/bin/activate && python ./litex_setup.py --init --install --config=full


target: litex
	#@echo $(PRUN) -m $(LITEX_BOARDS)/litex_boards/litex_boards.targets.digilent_arty --build --load
	export PATH=$$PATH:./scripts/:$(RISCV) && \
		source $(VIVADO_SETTINGS) && \
		CHIPDB=$(CHIPDB) $(PRUN) $(LITEX_BOARDS)/litex_boards/targets/$(TARGET).py $(TARGET_OPTIONS)  --build 

baremtal: target
	litex_bare_metal_demo --build-path=build/$(TARGET)

clean:
	rm -rf ./build/$(TARGET)

mrproper:
	rm -rf ./venv
	rm -rf ./litex/
	rm -rf ./build/
	deactivate

