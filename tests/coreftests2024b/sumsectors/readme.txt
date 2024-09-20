sumsectors.asm
--------------

The code reads and sums the contents of the first sectors in the disk drive,
and write the sum to mem[131].

The number of sectors to sum is 4, as given by the initial contents of
mem[128].

The disk contains running numbers. Therefore the sum of four sectors written
to mem[13] should be:

0+1+2+3+...+511 = 512/2 * 511 = 130816 = (0x1FF << 8) = 0x1FF00

The main code is using polling. Double buffer is used such that we sum a
sector in parallel to reading the next sector from the disk to the other
buffer in the background, saving overall execution time.

Disk interrupts are also enabled, but the code just increments $gp in the
irq handler and returns.

We check that:

- The output files regout.txt, diskout.txt, dmemout.txt are exactly as
  in the reference files provided.

- The running time of the program in cycles.txt is approximately equal to the reference.

- The file hwregtrace.txt contains the same writes to the hardware
  registers (addresses + contents). There should be 12 writes in four groups
  of 3, each group to disksector, diskbuffer and diskcmd. The four groups
  should be about 1024 cycles apart. In between, there should be many reads
  to diskstatus waiting for the disk to become ready. There should also be
  4 clears of irq1status. Cycle values may differ a bit.
