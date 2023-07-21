import type { WitnessTester } from "circomkit";
import { circomkit } from "./utils";
import { CircuitParameters } from "./types";

const ticks = [100, 200, 400];
const memsizes = [10, 20, 30];
const opsizes = [25, 50, 100];

let paramCombinations: CircuitParameters[] = [];

ticks.forEach((tick) => {
  memsizes.forEach((memsize) => {
    opsizes.forEach((opsize) => {
      paramCombinations.push({
        ticks: tick,
        memsize,
        opsize,
        insize: 2,
        outsize: 2,
      });
    });
  });
});

describe("constraints", () => {
  paramCombinations.map((params, i) =>
    describe(`\nticks: ${params.ticks}\tmem: ${params.memsize}\tops: ${params.opsize}`, () => {
      let circuit: WitnessTester<["ops", "inputs", "outputs"]>;

      before(async () => {
        circuit = await circomkit.WitnessTester("constraint-test", {
          file: "brainfuck",
          template: "Brainfuck",
          params: [params.ticks, params.memsize, params.opsize, params.insize, params.outsize],
          pubs: ["outputs"],
        });
      });

      it("should print constraits circuit", async () => {
        console.log("constraints:", await circuit.getConstraintCount());
      });
    })
  );
});
