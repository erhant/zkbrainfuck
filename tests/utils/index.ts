import type { CircuitExecution, CircuitParameters, ProgramExecution } from "../types";

export function prepareProgramForCircuit(program: ProgramExecution, circuit: CircuitParameters): CircuitExecution {
  if (program.ticks > circuit.ticks) throw new Error("Program ticks exceed circuit ticks.");
  if (program.memsize > circuit.memsize) throw new Error("Program memory exceed circuit memory.");
  if (program.insize > circuit.insize) throw new Error("Program inputs exceed circuit inputs.");
  if (program.outsize > circuit.outsize) throw new Error("Program outputs exceed circuit outputs.");
  if (program.opsize > circuit.opsize) throw new Error("Program operaitons exceed circuit operations.");

  return {
    ops: program.ops.concat(Array.from({ length: circuit.opsize - program.opsize }, () => 0)),
    inputs: program.inputs.concat(Array.from({ length: circuit.insize - program.insize }, () => 0)),
    outputs: program.outputs.concat(Array.from({ length: circuit.outsize - program.outsize }, () => 0)),
  };
}
