7seg.asm
--------

The code writes up, in a loop, the numbers 1 to 0x63 to the 7-segment
display.

In addition the code also tries to change registers $zero, $imm.
This is just to check that they are handled correctly -- not changed.

We check that:

- All output files are exactly as in the reference files provided.
