pragma circom 2.1.0;

include "./vm.circom"

// MEM: memory size
// LEN: code size
// CLK: number of clock-cycles
template Brainfuck(MEM, LEN, CLK) {
  signal input code[LEN];

  component vm = VM(MEM);

  // reset pointers & memory
  vm.i <== 0;
  vm.p <== 0;

  // reset memory
  for (var i = 0; i < M; i++) {
    vm.m[i] <== 0;
  }
}
