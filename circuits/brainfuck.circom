pragma circom 2.1.0;

include "./vm.circom"

template Brainfuck(CLOCKS, MEMSIZE) {
  signal input in[CLOCKS];
  signal input out[CLOCKS];
  signal input i[CLOCKS];
  signal input _i[CLOCKS];
  signal input p[CLOCKS];
  signal input _p[CLOCKS];
  signal input m[MEMSIZE][CLOCKS];
  signal input _m[MEMSIZE][CLOCKS];

  component vm = VM(MEM);

  // reset pointers & memory
  vm.i <== 0;
  vm.p <== 0;

  // reset memory
  for (var i = 0; i < M; i++) {
    vm.m[i] <== 0;
  }
}
