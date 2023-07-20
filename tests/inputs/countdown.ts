import type { TestCase } from "../types";

export const countdown: TestCase = {
  program: {
    ticks: 22,
    memsize: 0,
    opsize: 13,
    insize: 1,
    outsize: 5,
    ops: [0, 0, 0, 0, 0, 0, 0, 5, 11, 6, 4, 8, 0],
    inputs: [5],
    outputs: [5, 4, 3, 2, 1],
  },
  params: {
    insize: 1,
    outsize: 5,
    opsize: 15,
    memsize: 1,
    ticks: 30,
  },
  name: "countdown",
  num: true,
};
