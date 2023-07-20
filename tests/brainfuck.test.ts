import { Circomkit, type WitnessTester } from "circomkit";
import { prepareProgramForCircuit } from "./utils";
import { helloworld } from "./inputs";

const circomkit = new Circomkit({
  verbose: false,
});

[helloworld].map(({ program, params, name }) =>
  describe(`zkBrainfuck (${name})`, () => {
    let circuit: WitnessTester<["ops", "inputs", "outputs"]>;
    const INPUT = prepareProgramForCircuit(program, params);

    before(async () => {
      console.time("compiled in");
      circuit = await circomkit.WitnessTester(name, {
        file: "brainfuck",
        template: "Brainfuck",
        params: [params.ticks, params.memsize, params.opsize, params.insize, params.outsize],
      });
      console.timeEnd("compiled in");
      console.log("constraints:", await circuit.getConstraintCount());
    });

    it("should execute circuit", async () => {
      await circuit.expectPass(INPUT);
    });
  })
);
