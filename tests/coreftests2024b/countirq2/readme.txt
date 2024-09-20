countirq2.asm
-------------

The code uses the clock counter hardware register (number 8) to wait 1024
cycles and exit. During this time, the code accepts the user interrupt irq2 and
increments $t1 each time the interrupt happens.

irq2in.txt asks for irq every 100 cycles, starting from cycle 100. There
should therefore be 10 interrupts before the code exits.

We check that:

- At the end all registers should match, in particular $t1 should be 10.
- Run time should be slightly more than 1024 cycles.
