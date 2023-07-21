import type { WitnessTester } from "circomkit";
import { circomkit, prepareProgramForCircuit } from "./utils";
import { helloworld, countdown, multiply } from "./inputs";

describe("zkbrainfuck", () => {
  [multiply, countdown, helloworld].map(({ program, params, name }) =>
    describe(name, () => {
      let circuit: WitnessTester<["ops", "inputs", "outputs"]>;
      const INPUT = prepareProgramForCircuit(program, params);

      before(async () => {
        console.time("compiled in");
        circuit = await circomkit.WitnessTester(name, {
          file: "brainfuck",
          template: "Brainfuck",
          params: [params.ticks, params.memsize, params.opsize, params.insize, params.outsize],
          pubs: ["outputs", "ops"],
        });
        console.timeEnd("compiled in");
        console.log("constraints:", await circuit.getConstraintCount());
      });

      it("should execute circuit", async () => {
        await circuit.expectPass(INPUT);
      });
    })
  );
});
