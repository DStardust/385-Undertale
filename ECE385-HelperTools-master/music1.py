## This code generate a txt version file for a wav music file
## Which can be used for the FPGA audio module
## Author: Ge Yuhao

import numpy as np
import wave

music = wave.open("F:/Quartus-lite-18.1.0.625-windows/labs/Final/toby fox - UNDERTALE Soundtrack - 06 Uwa!! So Temperate_01.wav", 'r')
signal = music.readframes(-1)

soundwave = np.frombuffer(signal, dtype="uint16")

with open("F:/Quartus-lite-18.1.0.625-windows/labs/Final/music3.txt","w") as f:
    for i in soundwave:
        f.write('{:04X}'.format(i))
        f.write("\n")