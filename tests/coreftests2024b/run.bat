@echo off
set test_name=%1
echo %test_name%
cd %test_name%
echo %cd%


del asm.exe sim.exe memin1.txt memout1.txt regout1.txt trace1.txt hwregtrace1.txt cycles1.txt leds1.txt display7seg1.txt diskout1.txt monitor1.txt monitor1.yuv

copy "C:\Users\yair\Documents\project_c\Assembler\Assembler\Assembler.exe" asm.exe
copy "C:\Users\yair\Documents\project_c\simulator\simulator\simulator.exe" sim.exe
asm.exe %test_name%.asm memin1.txt
sim.exe memin1.txt diskin.txt irq2in.txt memout1.txt regout1.txt trace1.txt hwregtrace1.txt cycles1.txt leds1.txt display7seg1.txt diskout1.txt monitor1.txt monitor1.yuv


fc memin.txt memin1.txt
fc memout.txt memout1.txt
fc regout.txt regout1.txt
fc monitor.txt monitor1.txt
fc /b monitor.yuv monitor1.yuv
fc display7seg.txt display7seg1.txt
fc trace.txt trace1.txt
fc hwregtrace.txt hwregtrace1.txt
fc cycles.txt cycles1.txt
fc leds.txt leds1.txt
fc diskout.txt diskout1.txt

cd ..