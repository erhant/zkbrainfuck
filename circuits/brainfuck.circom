pragma circom 2.1.0;

include "./vm.circom";

template Brainfuck(CLOCKS, MEMSIZE, OPSIZE) {
  signal input ops[OPSIZE];
  signal input inputs[CLOCKS];
  signal output outputs[CLOCKS];

  signal mem_ptrs[CLOCKS];
  signal pgm_ctrs[CLOCKS];
  signal mems[CLOCKS][MEMSIZE];

  // initial state is all zeros
  mem_ptrs[0] <== 0;
  pgm_ctrs[0] <== 0;
  for (var i = 0; i < MEMSIZE; i++) {
    mems[0][i] <== 0;
  }

  // create a VM component for each execution step
  component vm[CLOCKS];
  for (var clk = 0; clk < CLOCKS - 1; clk++) {
    vm[clk] = VM(MEMSIZE, OPSIZE);
    vm[clk].mem <== mems[clk];
    vm[clk].pgm_ctr <== pgm_ctrs[clk];
    vm[clk].mem_ptr <== mem_ptrs[clk];
    vm[clk].in <== inputs[clk];
    vm[clk].op <== ArrayRead(OPSIZE)(ops, pgm_ctrs[clk]);

    // state transitions
    mems[clk+1] <== vm[clk].next_mem;
    pgm_ctrs[clk+1] <== vm[clk].next_pgm_ctr;
    mem_ptrs[clk+1] <== vm[clk].next_mem_ptr;

    // output
    outputs[clk] <== vm[clk].out;
  }
}
