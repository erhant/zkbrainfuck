import { Circomkit, WitnessTester } from "circomkit";
import { CircuitParameters, ProgramExecution } from "./types";
import { prepareProgramForCircuit } from "./utils";

const circomkit = new Circomkit();

const program: ProgramExecution = {
  ticks: 47,
  memsize: 0,
  opsize: 18,
  insize: 1,
  outsize: 10,
  ops: [0, 0, 0, 0, 0, 0, 0, 5, 3, 3, 3, 3, 3, 16, 4, 6, 13, 0],
  inputs: [5],
  outputs: [9, 8, 7, 6, 5, 4, 3, 2, 1, 0],
};
const params: CircuitParameters = {
  insize: 2,
  outsize: 15,
  opsize: 20,
  memsize: 10,
  ticks: 80,
};
describe("zkbrainfuck", () => {
  let circuit: WitnessTester<["ops", "inputs", "outputs"]>;
  const INPUT = prepareProgramForCircuit(program, params);

  before(async () => {
    circuit = await circomkit.WitnessTester("zkbrainfuck", {
      file: "brainfuck",
      template: "Brainfuck",
      params: [params.ticks, params.memsize, params.opsize, params.insize, params.outsize],
    });

    console.log("#constraints:", await circuit.getConstraintCount());
  });

  it("should execute circuit", async () => {
    console.log("executing...");
    await circuit.expectPass(INPUT);
  });
});
