import re

OP_RTYPE = 0b0110011
OP_ITYPE = 0b0010011
OP_LOAD  = 0b0000011
OP_STORE = 0b0100011
OP_BRANCH= 0b1100011

FUNCT3 = {
    "add":0b000, "sub":0b000, "and":0b111, "or":0b110,
    "addi":0b000, "ld":0b011, "sd":0b011, "beq":0b000
}

FUNCT7 = {
    "add":0b0000000, "sub":0b0100000, "and":0, "or":0
}

def reg(x):
    return int(x.replace("x",""))

def encode_rtype(op, rd, rs1, rs2):
    return (
        (FUNCT7[op] << 25) |
        (rs2 << 20) |
        (rs1 << 15) |
        (FUNCT3[op] << 12) |
        (rd << 7) |
        OP_RTYPE
    )

def encode_addi(rd, rs1, imm):
    imm &= 0xFFF
    return (
        (imm << 20) |
        (rs1 << 15) |
        (FUNCT3["addi"] << 12) |
        (rd << 7) |
        OP_ITYPE
    )

def encode_ld(rd, rs1, imm):
    imm &= 0xFFF
    return (
        (imm << 20) |
        (rs1 << 15) |
        (FUNCT3["ld"] << 12) |
        (rd << 7) |
        OP_LOAD
    )

def encode_sd(rs2, rs1, imm):
    imm &= 0xFFF
    imm11_5 = (imm >> 5) & 0x7F
    imm4_0  = imm & 0x1F

    return (
        (imm11_5 << 25) |
        (rs2 << 20) |
        (rs1 << 15) |
        (FUNCT3["sd"] << 12) |
        (imm4_0 << 7) |
        OP_STORE
    )

def encode_beq(rs1, rs2, offset):

    imm = offset

    b12   = (imm >> 12) & 1
    b10_5 = (imm >> 5) & 0x3F
    b4_1  = (imm >> 1) & 0xF
    b11   = (imm >> 11) & 1

    return (
        (b12 << 31) |
        (b10_5 << 25) |
        (rs2 << 20) |
        (rs1 << 15) |
        (FUNCT3["beq"] << 12) |
        (b4_1 << 8) |
        (b11 << 7) |
        OP_BRANCH
    )

# ---------------- PASS 1 : COLLECT LABELS ----------------

labels = {}
instructions = []

with open("code.txt") as f:

    pc = 0

    for line in f:

        line = line.strip()

        if not line:
            continue

        if ":" in line:
            label = line.replace(":", "").strip()
            labels[label] = pc
            continue

        instructions.append((pc, line))
        pc += 4

# ---------------- PASS 2 : ENCODE INSTRUCTIONS ----------------

machine = []

for pc, line in instructions:

    line = line.replace(",", " ")
    parts = line.split()

    op = parts[0].lower()

    if op in ["add", "sub", "and", "or"]:

        rd  = reg(parts[1])
        rs1 = reg(parts[2])
        rs2 = reg(parts[3])

        machine.append(encode_rtype(op, rd, rs1, rs2))

    elif op == "addi":

        rd  = reg(parts[1])
        rs1 = reg(parts[2])
        imm = int(parts[3])

        machine.append(encode_addi(rd, rs1, imm))

    elif op == "ld":

        rd = reg(parts[1])
        imm, rs1 = re.match(r'(-?\d+)\(x(\d+)\)', parts[2]).groups()

        machine.append(encode_ld(rd, int(rs1), int(imm)))

    elif op == "sd":

        rs2 = reg(parts[1])
        imm, rs1 = re.match(r'(-?\d+)\(x(\d+)\)', parts[2]).groups()

        machine.append(encode_sd(rs2, int(rs1), int(imm)))

    elif op == "beq":

        rs1 = reg(parts[1])
        rs2 = reg(parts[2])

        target = parts[3]

        if target in labels:
            offset = labels[target] - pc
        else:
            offset = int(target)

        machine.append(encode_beq(rs1, rs2, offset))

# ---------------- WRITE instructions.txt ----------------

with open("instructions.txt", "w") as f:

    for inst in machine:

        bytes_list = [
            (inst >> 24) & 0xFF,
            (inst >> 16) & 0xFF,
            (inst >> 8) & 0xFF,
            inst & 0xFF
        ]

        for b in bytes_list:
            f.write(f"{b:02x}\n")