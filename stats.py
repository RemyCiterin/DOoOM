# Display the statistic (in term of surface) of each verilog modules of the
# design

import numpy
import matplotlib.pyplot as plt
import json
import re

file = open("./build/mkTop.json", "r")
file = json.loads(file.read())

class Module:
    def __init__(self, names):
        self.count = 0
        self.patterns = [re.compile(n + "*") for n in names]
        self.name = names[0]

    def match(self, name):
        if any((p.match(name) for p in self.patterns)):
            self.count += 1
            return True
        else:
            return False

def match(l, name):
    return any([x.match(name) for x in l])

modules = [
    Module(["cpu.vga", "cpu.CAN_FIRE_RL_vga", "cpu.IF_0_CONCAT_0_CONCAT_vga"]),
    Module(["cpu.uart", "cpu.CAN_FIRE_RL_uart"]),
    Module(["cpu.dcache", "cpu.CAN_FIRE_RL_dcache"]),
    #Module("cpu"),
    Module(["cpu.rom", "cpu.IF_rom"]),
    Module(["cpu.core"]),
    Module(["cpu.rd_port", "cpu.wr_port", "cpu.CAN_FIRE_RL_rd_port",
    "cpu.CAN_FIRE_RL_wr_port", "cpu.rdata", "cpu.sendRspTo", "cpu.sendDataTo",
    "cpu.receiveRspFrom", "cpu.wrAddr", "cpu.rlast", "cpu.value", "cpu.requests"]),
    Module(["cpu.btn"]),
    Module(["sdram"]),
    Module(["fake_differential"]),
    Module(["vga2dvid"]),
]

for name in file["modules"]["mkTop"]["cells"]:

    if match(modules, name):
        pass
    else:
        print(name)

print()

for m in modules:
    print("name: {}    count: {}".format(m.name, m.count))
