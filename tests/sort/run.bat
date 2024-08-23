@echo off

del memin.txt memout.txt regout.txt trace.txt hwregtrace.txt cycles.txt leds.txt display7seg.txt diskout.txt monitor.txt monitor.yuv

copy "C:\Users\yair\Documents\project_c\simulator\simulator\simulator.exe" .\sim.exe
copy "C:\Users\yair\Documents\project_c\Assembler\Assembler\Assembler.exe" .\asm.exe
asm.exe sort.asm memin.txt
sim.exe memin.txt diskin.txt irq2in.txt memout.txt regout.txt trace.txt hwregtrace.txt cycles.txt leds.txt display7seg.txt diskout.txt monitor.txt monitor.yuv

fc memout.txt memout_opt.txt