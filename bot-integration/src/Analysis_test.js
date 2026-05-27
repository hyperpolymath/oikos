// SPDX-License-Identifier: MPL-2.0
// SPDX-FileCopyrightText: 2026 hyperpolymath
//
// Regression tests for Analysis.decodeAnalysisResult — the decoder that
// replaced the previous `Obj.magic` cast. The cast crashed downstream on any
// schema drift; these tests pin the schema contract.

import { decodeAnalysisResult } from "./Analysis.res.js";
import { assertEquals, assert } from "jsr:@std/assert@^1.0.0";

const validPayload = {
  eco: { carbonScore: 80.0, energyScore: 70.0, resourceScore: 75.0, score: 75.0 },
  econ: {
    paretoDistance: 0.1,
    allocationScore: 90.0,
    debtScore: 60.0,
    score: 80.0,
    paretoStatus: { isOptimal: false, distance: 0.1, improvements: ["cache reads"] },
  },
  quality: { complexityScore: 70.0, couplingScore: 80.0, coverageScore: 85.0, score: 78.0 },
  health: { eco: 0.4, econ: 0.3, quality: 0.3, total: 77.5, grade: "B" },
  violations: [
    {
      entityId: "src/a.rs",
      policy: "eco_minimum",
      severity: "high",
      message: "carbon score below threshold",
      suggestions: ["batch I/O"],
    },
  ],
  recommendations: [
    {
      entityId: "src/b.rs",
      action: "vectorize",
      reason: "hot loop",
      priority: "medium",
      confidence: 0.8,
      expectedImprovement: { carbonScore: 5.0 },
    },
  ],
  timestamp: "2026-05-27T00:00:00Z",
  commitSha: "deadbeef",
};

Deno.test("decodeAnalysisResult: valid payload round-trips", () => {
  const result = decodeAnalysisResult(validPayload);
  assertEquals(result.TAG, "Ok");
  assertEquals(result._0.eco.score, 75.0);
  assertEquals(result._0.health.grade, "B");
  assertEquals(result._0.violations.length, 1);
  assertEquals(result._0.recommendations[0].confidence, 0.8);
});

Deno.test("decodeAnalysisResult: missing required field is Error", () => {
  const bad = { ...validPayload };
  delete bad.health;
  const result = decodeAnalysisResult(bad);
  assertEquals(result.TAG, "Error");
  assert(result._0.includes("health"));
});

Deno.test("decodeAnalysisResult: wrong field type is Error, not crash", () => {
  const bad = { ...validPayload, eco: "not an object" };
  const result = decodeAnalysisResult(bad);
  assertEquals(result.TAG, "Error");
  assert(result._0.includes("eco"));
});

Deno.test("decodeAnalysisResult: unknown severity rejected", () => {
  const bad = {
    ...validPayload,
    violations: [{ ...validPayload.violations[0], severity: "catastrophic" }],
  };
  const result = decodeAnalysisResult(bad);
  assertEquals(result.TAG, "Error");
  assert(result._0.includes("severity"));
});

Deno.test("decodeAnalysisResult: optional fields default cleanly", () => {
  // JSON.parse never emits `undefined` keys, only missing ones — model that.
  const econ = { ...validPayload.econ };
  delete econ.paretoStatus;
  const minimal = {
    eco: validPayload.eco,
    econ,
    quality: validPayload.quality,
    health: validPayload.health,
    timestamp: validPayload.timestamp,
  };
  const result = decodeAnalysisResult(minimal);
  assertEquals(result.TAG, "Ok");
  assertEquals(result._0.violations.length, 0);
  assertEquals(result._0.recommendations.length, 0);
  assertEquals(result._0.commitSha, undefined);
});

Deno.test("decodeAnalysisResult: top-level non-object is Error", () => {
  const result = decodeAnalysisResult("not an object");
  assertEquals(result.TAG, "Error");
});
