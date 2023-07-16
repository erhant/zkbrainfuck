import { Circomkit, WitnessTester } from "circomkit";

// exercise: make this test work for all numbers, not just 3
describe("multiplier", () => {
  let circuit: WitnessTester<["in"], ["out"]>;

  before(async () => {
    const circomkit = new Circomkit();
    circuit = await circomkit.WitnessTester('multiplier_3', {
      file: "multiplier",
      template: "Multiplier",
      params: [3],
    });
  });

  it("should multiply correctly", async () => {
    await circuit.expectPass({ in: [2, 4, 10] }, { out: 80 });
  });
});
