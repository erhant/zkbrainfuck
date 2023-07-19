pragma circom 2.1.0;

include "./vm.circom"

template Brainfuck(CLOCKS, MEMSIZE) {
  signal input i[CLOCKS];
  signal input p[CLOCKS];
  signal input m[CLOCKS][MEMSIZE];

  // create a VM component for each execution step
  component vm[CLOCKS];
  for (var clk = 0; clk < CLOCKS - 1; clk++) {
    vm[clk] = VM(MEMSIZE);

    vm[clk].i <== i[clk];
    vm[clk]._i <== i[clk+1];

    vm[clk].p <== p[clk];
    vm[clk]._p <== p[clk+1];

    vm[clk].m <== m[clk];
    vm[clk]._m <== m[clk+1];
  }
}
