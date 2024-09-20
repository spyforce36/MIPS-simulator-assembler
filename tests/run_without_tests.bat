@echo off
set test_name=%1
echo %test_name%
cd %test_name%
echo %cd%


del asm.exe sim.exe memin.txt memout.txt regout.txt trace.txt hwregtrace.txt cycles.txt leds.txt display7seg.txt diskout.txt monitor.txt monitor.yuv

copy "C:\Users\yair\Documents\project_c\Assembler\Assembler\Assembler.exe" asm.exe
copy "C:\Users\yair\Documents\project_c\simulator\simulator\simulator.exe" sim.exe
asm.exe %test_name%.asm memin1.txt
sim.exe memin1.txt diskin.txt irq2in.txt memout1.txt regout1.txt trace1.txt hwregtrace1.txt cycles1.txt leds1.txt display7seg1.txt diskout1.txt monitor1.txt monitor1.yuv

cd ..
