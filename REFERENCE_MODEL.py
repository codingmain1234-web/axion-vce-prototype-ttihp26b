"""Simple software reference model for the AXION Gen0 core."""

def s8(x):
    x &= 0xff
    return x - 256 if x & 0x80 else x

def relu_sat(x):
    if x < 0:
        return 0
    if x > 127:
        return 127
    return x

class AXIONGen0:
    def __init__(self):
        self.a = 0
        self.b = 0
        self.acc = 0

    def vcore(self, op):
        if op == 0:
            return (self.a + self.b) & 0xff
        if op == 1:
            return (self.a - self.b) & 0xff
        if op == 2:
            return (self.a * self.b) & 0xff
        if op == 3:
            return self.a & self.b
        if op == 4:
            return self.a ^ self.b
        if op == 5:
            return max(self.a, self.b)
        raise ValueError("V-Core opcode must be in the range 0..5")

    def mac(self):
        self.acc += s8(self.a) * s8(self.b)
        # emulate 24-bit signed wrap
        self.acc &= (1 << 24) - 1
        if self.acc & (1 << 23):
            self.acc -= (1 << 24)
        return relu_sat(self.acc)

if __name__ == "__main__":
    v = AXIONGen0()
    v.a, v.b = 250, 10
    assert v.vcore(0) == 4
    v.a, v.b = 20, 13
    assert v.vcore(2) == 4
    v.a, v.b = 5, 3
    assert v.mac() == 15
    v.a, v.b = 0xFE, 4
    assert v.mac() == 7
    print("reference model checks passed")
