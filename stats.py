# Display the statistic (in term of surface) of each verilog modules of the
# design

import json
import re

file = open("./build/mkTop.json", "r")
file = json.loads(file.read())

class Module:
    def __init__(self, names):
        self.count = 0
        self.patterns = [re.compile(n + "*") for n in names]
        self.types = {}
        self.name = names[0]

    def match(self, name, typ):
        if any((p.match(name) for p in self.patterns)):
            self.count += 1

            if not typ in self.types:
                self.types[typ] = 0
            self.types[typ] += 1

            return True
        else:
            return False

def match(l, name, typ):
    return any([x.match(name, typ) for x in l])

modules = [
    Module(["cpu.vga", "cpu.CAN_FIRE_RL_vga", "cpu.IF_0_CONCAT_0_CONCAT_vga"]),
    Module(["cpu.uart", "cpu.CAN_FIRE_RL_uart"]),
    Module(["cpu.icache", "cpu.CAN_FIRE_RL_icache"]),
    Module(["cpu.core.lsu.cache", "cpu.core.lsu.CAN_FIRE_RL_cache"]),
    Module(["cpu"]),
    Module(["cpu.rom", "cpu.IF_rom"]),

    Module(["cpu.core"]),

    # pipelined CPU
    #Module(["cpu.core.window"]),
    #Module(["cpu.core.bpred_state"]),
    #Module(["cpu.core.decoded"]),
    #Module(["cpu.core.alu"]),
    #Module(["cpu.core.csr"]),
    #Module(["cpu.core.registers"]),
    #Module(["cpu.core.control"]),
    #Module(["cpu.core.fetch"]),
    #Module(["cpu.core.timer"]),
    #Module(["cpu.core.dmem", "cpu.core.master"]),

    # out-of-order CPU
    Module(["cpu.core.csr", "cpu.core.MUX_csr"]),
    Module(["cpu.core.rob", "cpu.core.CASE_rob"]),
    Module(["cpu.core.alu_issue_queue", "cpu.core.IF_alu_issue_queue",
            "cpu.core.CASE_m7493_BIT_0_0_alu_issue_queue"]),
    Module(["cpu.core.alu_fu"]),
    Module(["cpu.core.control_issue_queue", "cpu.core.IF_control_issue_queue"]),
    Module(["cpu.core.direct_issue_queue", "cpu.core.IF_direct_issue_queue"]),
    Module(["cpu.core.control_fu"]),
    Module(["cpu.core.lsu"]),
    Module(["cpu.core.lsu.storeAddrIQ"]),
    Module(["cpu.core.lsu.storeDataIQ"]),
    Module(["cpu.core.lsu.loadIQ"]),
    Module(["cpu.core.lsu.storeQ"]),
    Module(["cpu.core.lsu.loadQ"]),
    Module(["cpu.core.lsu.stb"]),
    Module(["cpu.core.registers"]),
    Module(["cpu.core.master"]),
    Module(["cpu.core.fetch", "cpu.core.CASE_fetch"]),


    Module(["cpu.rd_port", "cpu.wr_port", "cpu.CAN_FIRE_RL_rd_port",
    "cpu.CAN_FIRE_RL_wr_port", "cpu.rdata", "cpu.sendRspTo", "cpu.sendDataTo",
    "cpu.receiveRspFrom", "cpu.wrAddr", "cpu.rlast", "cpu.value", "cpu.requests"]),
    Module(["cpu.sdcard"]),
    Module(["cpu.btn"]),
    Module(["sdram"]),
    Module(["fake_differential"]),
    Module(["vga2dvid"]),
]

for name in file["modules"]["mkTop"]["cells"]:

    if match(modules, name, file["modules"]["mkTop"]["cells"][name]["type"]):
        pass
    else:
        print(name, file["modules"]["mkTop"]["cells"][name]["type"])

for m in modules:
    if m.count > 0:
        print(m.name)

        for t in m.types:
            print("\t| {}: {}".format(t, m.types[t]))

        print("\t+---------\n\ttotal: {}".format(m.count))
