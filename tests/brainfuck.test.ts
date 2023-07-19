import { Circomkit, WitnessTester } from "circomkit";

const [MEMSIZE, CLOCKS] = [128, 1 << 16];
describe("multiplier", () => {
  let circuit: WitnessTester<["i", "p", "m"]>;

  before(async () => {
    const circomkit = new Circomkit();
    circuit = await circomkit.WitnessTester("zkbrainfuck", {
      file: "brainfuck",
      template: "Brainfuck",
      params: [CLOCKS, MEMSIZE],
    });
  });
});
