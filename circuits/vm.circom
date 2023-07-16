pragma circom 2.0.0;

template Brainfuck(SIZE) {
  component vm = VM(SIZE);
  vm.i <== 0;
  vm.p <== 0;
  for (var i = 0; i < SIZE; i++) {
    vm.m[i] <== 0;
  }
}

template VM(SIZE) {
  // previous state
  signal input i;
  signal input p;
  signal input m[SIZE];

  // next state
  signal output _i;
  signal output _p;
  signal output _m[SIZE];

}