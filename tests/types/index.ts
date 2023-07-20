/** A program execution output from Go VM. */
export type ProgramExecution = {
  ticks: number;
  memsize: number;
  opsize: number;
  insize: number;
  outsize: number;
  ops: number[];
  inputs: number[];
  outputs: number[];
};

/**
 * A `ProgramExecution` converted to be suitable for circuit.
 *
 * The difference is that `ops`, `inputs` and `outputs` will all be appended
 * zeros to match the circuit parameters.
 *
 * For example, if we have 4 inputs but circuit expects 10, we add 6 zeros to the input.
 */
export type CircuitExecution = {
  ops: number[];
  inputs: number[];
  outputs: number[];
};

/** Circuit template parameters. */
export type CircuitParameters = {
  ticks: number;
  memsize: number;
  opsize: number;
  insize: number;
  outsize: number;
};

/** A test case */
export type TestCase = {
  program: ProgramExecution;
  params: CircuitParameters;
  name: string;
  /** treat the memory as integers (true) or ASCII (false)? */
  num: boolean;
};
