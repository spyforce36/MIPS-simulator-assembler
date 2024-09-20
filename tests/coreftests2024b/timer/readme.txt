timer.asm
---------

The code sets up a timer interrupt to fire every second.
In the timer irq handler, on each entry we:

1. Shift the current led pattern to the left and light up a new led on the right.
2. Write a new pixel on a diagonal line at coordinates (x,y). The
coordinates start at 0, and both x and y are incremented each time.
3. Increments mem[256], which counts the number of times we got to the irq
handler.

The main code waits until it detects mem[256] being equal to mem[257], then
exits.

Since mem[257] is initialized to 7, the timer interrupt fires 7 times before
exiting.

We check that:

- The output files regout.txt, diskout.txt, dmemout.txt, monitor.txt,
  monitor.yuv are exactly as in the reference files provided.

- The running time of the program in cycles.txt is approximately equal to the reference.

- The file leds.txt contains 7 lines with the same patterns as in the
  reference. Cycle numbers can vary a bit but the difference in cycles
  between each two lines should be approximately 1024 cycles.

- The file hwregtrace.txt contains the same reads/writes to the hardware
  registers (addresses + contents). Cycle values may differ a bit.
