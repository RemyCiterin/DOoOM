import matplotlib.pyplot as plt
import numpy as np

# return the RGB encoding of a pixel
def read_byte(byte: int):
    values = [0x0,0x24,0x49,0x6d,0x92,0xb6,0xdb,0xff]
    r = values[byte >> 5]
    g = values[(byte >> 2) & 7]
    b = [0,0x55,0xaa,0xff][byte & 3]
    return np.array([r,g,b], dtype=np.uint8)

buffer = np.zeros((240, 320, 3), dtype=np.uint8)

def write_byte(addr, color):
    y = addr // 320
    x = addr % 320
    buffer[y,x] = color

def write_buffer(addr, data, mask):
    aligned = addr << 2

    data0 = read_byte(data & 255)
    data1 = read_byte((data >> 8) & 255)
    data2 = read_byte((data >> 16) & 255)
    data3 = read_byte((data >> 24) & 255)

    if mask & 1 != 0: write_byte(aligned, data0)
    if mask & 2 != 0: write_byte(aligned+1, data1)
    if mask & 4 != 0: write_byte(aligned+2, data2)
    if mask & 8 != 0: write_byte(aligned+3, data3)

file = open("screen.txt", "r")

while True:
    # parse a line as strings
    line = [int(x) for x in file.readline()[:-1].split(' ') if x != '']

    if len(line) == 0:
        break
    else:
        addr, data, mask = line
        write_buffer(addr, data, mask)

plt.imshow(buffer, interpolation="none")
plt.show()
