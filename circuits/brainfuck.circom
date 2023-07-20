pragma circom 2.1.0;

include "./vm.circom";

//       _---~~(~~-_.
//     _{        )   )          Brainfuck ZKVM
//   ,   ) -~~- ( ,-' )_        for Circom v2.1.0
//  (  `-,_..`., )-- '_,)       by erhant
// ( ` _)  (  -~( -_ `,  }      
// (_-  _  ~_-~~~~`,  ,' )      Art by: 
//   `~ -^(    __;-,((()))      Steven James Walker
//         ~~~~ {_ -_(())       https://www.asciiart.eu/people/body-parts/brains
//                `\  }         
//                   { } 
//
// Executes a compiled Brainfuck program with the given inputs, proving the
// correctness of outputs for the given program while hiding the inputs.
//
// The output is assigned from the VM itself, but is given by the prover and
// asserted inside. This solves the "signal already assigned" problem because 
// now instead of writing the output of a tick, we can read the currently 
// pointed output and assert correctness.
//
// If there are less ops, inputs or outputs than the size provided in template
// parameters, we expect the remaining size to be filled with zeros. They do not
// necessarily alter the program execution though.
//
// Parameters:
// - `TICKS`: number of ticks to run
// - `MEMSIZE`: maximum memory size
// - `OPSIZE`: maximum number of operations
// - `INSIZE`: maximum number of inputs
// - `OUTSIZE`: maximum number of outputs
//
// Inputs:
// - `ops`: compiled code, as an array of integers where 0 is no-op
// - `inputs`: inputs in the order they appear, append zeros for no input
// - `outputs`: outputs in the order they appear, append zeros for no output
//
template Brainfuck(TICKS, MEMSIZE, OPSIZE, INSIZE, OUTSIZE) {
  signal input ops[OPSIZE];
  signal input inputs[INSIZE];
  signal input outputs[OUTSIZE];

  signal pgm_ctrs[TICKS];
  signal mem_ptrs[TICKS];
  signal input_ptrs[TICKS];
  signal output_ptrs[TICKS];
  signal mems[TICKS][MEMSIZE];

  // ops must be zero-padded
  for (var i = 0; i < 7; i++) {
    ops[i] === 0;
  }
  // last possible op must be no-op
  ops[OPSIZE - 1] === 0;

  pgm_ctrs[0] <== 7; // skip prepended zeros
  mem_ptrs[0] <== 0;
  input_ptrs[0] <== 0;
  output_ptrs[0] <== 0;
  // entire memory is zeros at first
  for (var i = 0; i < MEMSIZE; i++) {
    mems[0][i] <== 0;
  }
  
  component vm[TICKS - 1];
  for (var tick = 0; tick < TICKS - 1; tick++) {
    vm[tick] = VM(MEMSIZE, OPSIZE);

    vm[tick].mem <== mems[tick];
    vm[tick].pgm_ctr <== pgm_ctrs[tick];
    vm[tick].mem_ptr <== mem_ptrs[tick];
    vm[tick].input_ptr <== input_ptrs[tick];
    vm[tick].output_ptr <== output_ptrs[tick];
    vm[tick].op <== ArrayRead(OPSIZE)(ops, pgm_ctrs[tick]);
    vm[tick].in <== ArrayRead(INSIZE)(inputs, input_ptrs[tick]);
    vm[tick].out <== ArrayRead(OUTSIZE)(outputs, output_ptrs[tick]);

    vm[tick].next_mem ==> mems[tick+1];
    vm[tick].next_pgm_ctr ==> pgm_ctrs[tick+1];
    vm[tick].next_mem_ptr ==> mem_ptrs[tick+1];
    vm[tick].next_input_ptr ==> input_ptrs[tick+1];
    vm[tick].next_output_ptr ==> output_ptrs[tick+1];
  }
}
