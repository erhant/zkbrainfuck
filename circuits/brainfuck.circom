pragma circom 2.1.0;

include "./vm.circom";

// A Brainfuck program execution.
template Brainfuck(CLOCKS, MEMSIZE, OPSIZE, INSIZE, OUTSIZE) {
  signal input ops[OPSIZE];
  signal input inputs[INSIZE];
  signal input outputs[OUTSIZE];

  signal mem_ptrs[CLOCKS];
  mem_ptrs[0] <== 0;

  signal input_ptrs[CLOCKS];
  input_ptrs[0] <== 0;
  
  signal output_ptrs[CLOCKS];
  output_ptrs[0] <== 0;

  signal mems[CLOCKS][MEMSIZE];
  for (var i = 0; i < MEMSIZE; i++) {
    mems[0][i] <== 0;
  }

  signal pgm_ctrs[CLOCKS];
  pgm_ctrs[0] <== 7; // skip prepended zeros
  for (var i = 0; i < 7; i++) {
    ops[i] === 0;
  }

  // at worst, the last op must be a NO_OP
  // effectively halting the program until we run out of clocks
  ops[OPSIZE-1] === 0;

  // create a VM component for each execution step
  component vm[CLOCKS];
  for (var clk = 0; clk < CLOCKS - 1; clk++) {
    vm[clk] = VM(MEMSIZE, OPSIZE);
    vm[clk].mem <== mems[clk];
    vm[clk].pgm_ctr <== pgm_ctrs[clk];
    vm[clk].mem_ptr <== mem_ptrs[clk];
    vm[clk].input_ptr <== input_ptrs[clk];
    vm[clk].output_ptr <== output_ptrs[clk];
    vm[clk].in <== ArrayRead(INSIZE)(inputs, input_ptrs[clk]);
    vm[clk].op <== ArrayRead(OPSIZE)(ops, pgm_ctrs[clk]);

    // state transitions
    mems[clk+1] <== vm[clk].next_mem;
    pgm_ctrs[clk+1] <== vm[clk].next_pgm_ctr;
    mem_ptrs[clk+1] <== vm[clk].next_mem_ptr;
    input_ptrs[clk+1] <== vm[clk].next_input_ptr;
    output_ptrs[clk+1] <== vm[clk].next_output_ptr;

    // assert output
    var out = ArrayRead(OUTSIZE)(outputs, output_ptrs[clk]);
    out === vm[clk].out;
  }
}
