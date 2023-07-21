import type { TestCase } from "../types";

export const multiply: TestCase = {
  program: {
    ticks: 1672,
    memsize: 3,
    opsize: 41,
    insize: 2,
    outsize: 1,
    ops: [
      0, 0, 0, 0, 0, 0, 0, 5, 1, 5, 2, 36, 1, 21, 4, 1, 3, 1, 3, 2, 2, 13, 1, 1, 31, 4, 2, 2, 3, 1, 1, 24, 2, 2, 2, 4,
      11, 1, 1, 6, 0,
    ],
    inputs: [13, 7],
    outputs: [91],
  },
  params: {
    insize: 2,
    outsize: 1,
    opsize: 42,
    memsize: 4,
    ticks: 1700,
  },
  name: "multiply",
  num: true,
};
