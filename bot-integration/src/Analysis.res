// SPDX-License-Identifier: MPL-2.0
// SPDX-FileCopyrightText: 2024-2025 hyperpolymath
//
// Analysis service client.
//
// Decoder rationale: the analyzer is an external service that can drift from
// the bot's expected schema. Validating responses here means a malformed or
// partial payload yields a clean `Error(...)` instead of a runtime crash
// downstream (e.g. when generating a PR comment).

open Types

// -----------------------------------------------------------------------------
// JSON decoders — explicit, no Obj.magic
// -----------------------------------------------------------------------------

let decodeField = (obj: Js.Dict.t<Js.Json.t>, key: string): result<Js.Json.t, string> =>
  switch Js.Dict.get(obj, key) {
  | Some(v) => Ok(v)
  | None => Error(`missing field: ${key}`)
  }

let decodeOptField = (obj: Js.Dict.t<Js.Json.t>, key: string): option<Js.Json.t> =>
  switch Js.Dict.get(obj, key) {
  | Some(v) =>
    switch Js.Json.classify(v) {
    | Js.Json.JSONNull => None
    | _ => Some(v)
    }
  | None => None
  }

let asObject = (path: string, json: Js.Json.t): result<Js.Dict.t<Js.Json.t>, string> =>
  switch Js.Json.decodeObject(json) {
  | Some(obj) => Ok(obj)
  | None => Error(`${path}: expected object`)
  }

let asString = (path: string, json: Js.Json.t): result<string, string> =>
  switch Js.Json.decodeString(json) {
  | Some(s) => Ok(s)
  | None => Error(`${path}: expected string`)
  }

let asFloat = (path: string, json: Js.Json.t): result<float, string> =>
  switch Js.Json.decodeNumber(json) {
  | Some(n) => Ok(n)
  | None => Error(`${path}: expected number`)
  }

let asInt = (path: string, json: Js.Json.t): result<int, string> =>
  asFloat(path, json)->Belt.Result.map(Belt.Float.toInt)

let asBool = (path: string, json: Js.Json.t): result<bool, string> =>
  switch Js.Json.decodeBoolean(json) {
  | Some(b) => Ok(b)
  | None => Error(`${path}: expected boolean`)
  }

let asArray = (path: string, json: Js.Json.t): result<array<Js.Json.t>, string> =>
  switch Js.Json.decodeArray(json) {
  | Some(a) => Ok(a)
  | None => Error(`${path}: expected array`)
  }

let mapArray = (
  arr: array<Js.Json.t>,
  decoder: (string, Js.Json.t) => result<'a, string>,
  path: string,
): result<array<'a>, string> => {
  let out = []
  let err = ref(None)
  Belt.Array.forEachWithIndex(arr, (i, item) => {
    if err.contents == None {
      switch decoder(`${path}[${Belt.Int.toString(i)}]`, item) {
      | Ok(v) => Js.Array2.push(out, v)->ignore
      | Error(e) => err := Some(e)
      }
    }
  })
  switch err.contents {
  | Some(e) => Error(e)
  | None => Ok(out)
  }
}

let decodeFloatField = (
  obj: Js.Dict.t<Js.Json.t>,
  path: string,
  key: string,
): result<float, string> =>
  decodeField(obj, key)->Belt.Result.flatMap(v => asFloat(`${path}.${key}`, v))

let decodeStringField = (
  obj: Js.Dict.t<Js.Json.t>,
  path: string,
  key: string,
): result<string, string> =>
  decodeField(obj, key)->Belt.Result.flatMap(v => asString(`${path}.${key}`, v))

let decodeBoolField = (
  obj: Js.Dict.t<Js.Json.t>,
  path: string,
  key: string,
): result<bool, string> =>
  decodeField(obj, key)->Belt.Result.flatMap(v => asBool(`${path}.${key}`, v))

let decodeEcoMetrics = (path: string, json: Js.Json.t): result<ecoMetrics, string> =>
  asObject(path, json)->Belt.Result.flatMap(obj => {
    switch (
      decodeFloatField(obj, path, "carbonScore"),
      decodeFloatField(obj, path, "energyScore"),
      decodeFloatField(obj, path, "resourceScore"),
      decodeFloatField(obj, path, "score"),
    ) {
    | (Ok(c), Ok(e), Ok(r), Ok(s)) =>
      Ok({carbonScore: c, energyScore: e, resourceScore: r, score: s})
    | (Error(e), _, _, _) | (_, Error(e), _, _) | (_, _, Error(e), _) | (_, _, _, Error(e)) =>
      Error(e)
    }
  })

let decodeImprovements = (path: string, json: Js.Json.t): result<array<string>, string> =>
  asArray(path, json)->Belt.Result.flatMap(arr => mapArray(arr, asString, path))

let decodeParetoStatus = (path: string, json: Js.Json.t): result<paretoStatus, string> =>
  asObject(path, json)->Belt.Result.flatMap(obj => {
    let isOptimal = decodeBoolField(obj, path, "isOptimal")
    let distance = decodeFloatField(obj, path, "distance")
    let improvements = switch decodeOptField(obj, "improvements") {
    | Some(v) =>
      decodeImprovements(`${path}.improvements`, v)->Belt.Result.map(arr => Some(arr))
    | None => Ok(None)
    }
    switch (isOptimal, distance, improvements) {
    | (Ok(o), Ok(d), Ok(imps)) => Ok({isOptimal: o, distance: d, improvements: imps})
    | (Error(e), _, _) | (_, Error(e), _) | (_, _, Error(e)) => Error(e)
    }
  })

let decodeEconMetrics = (path: string, json: Js.Json.t): result<econMetrics, string> =>
  asObject(path, json)->Belt.Result.flatMap(obj => {
    let paretoDistance = decodeFloatField(obj, path, "paretoDistance")
    let allocationScore = decodeFloatField(obj, path, "allocationScore")
    let debtScore = decodeFloatField(obj, path, "debtScore")
    let score = decodeFloatField(obj, path, "score")
    let paretoStatus = switch decodeOptField(obj, "paretoStatus") {
    | Some(v) =>
      decodeParetoStatus(`${path}.paretoStatus`, v)->Belt.Result.map(ps => Some(ps))
    | None => Ok(None)
    }
    switch (paretoDistance, allocationScore, debtScore, score, paretoStatus) {
    | (Ok(pd), Ok(a), Ok(d), Ok(s), Ok(ps)) =>
      Ok({
        paretoDistance: pd,
        allocationScore: a,
        debtScore: d,
        score: s,
        paretoStatus: ps,
      })
    | (Error(e), _, _, _, _)
    | (_, Error(e), _, _, _)
    | (_, _, Error(e), _, _)
    | (_, _, _, Error(e), _)
    | (_, _, _, _, Error(e)) =>
      Error(e)
    }
  })

let decodeQualityMetrics = (path: string, json: Js.Json.t): result<qualityMetrics, string> =>
  asObject(path, json)->Belt.Result.flatMap(obj => {
    switch (
      decodeFloatField(obj, path, "complexityScore"),
      decodeFloatField(obj, path, "couplingScore"),
      decodeFloatField(obj, path, "coverageScore"),
      decodeFloatField(obj, path, "score"),
    ) {
    | (Ok(c), Ok(co), Ok(cv), Ok(s)) =>
      Ok({complexityScore: c, couplingScore: co, coverageScore: cv, score: s})
    | (Error(e), _, _, _) | (_, Error(e), _, _) | (_, _, Error(e), _) | (_, _, _, Error(e)) =>
      Error(e)
    }
  })

let decodeHealthIndex = (path: string, json: Js.Json.t): result<healthIndex, string> =>
  asObject(path, json)->Belt.Result.flatMap(obj => {
    switch (
      decodeFloatField(obj, path, "eco"),
      decodeFloatField(obj, path, "econ"),
      decodeFloatField(obj, path, "quality"),
      decodeFloatField(obj, path, "total"),
      decodeStringField(obj, path, "grade"),
    ) {
    | (Ok(e), Ok(ec), Ok(q), Ok(t), Ok(g)) =>
      Ok({eco: e, econ: ec, quality: q, total: t, grade: g})
    | (Error(e), _, _, _, _)
    | (_, Error(e), _, _, _)
    | (_, _, Error(e), _, _)
    | (_, _, _, Error(e), _)
    | (_, _, _, _, Error(e)) =>
      Error(e)
    }
  })

let decodeSeverity = (path: string, json: Js.Json.t): result<severity, string> =>
  asString(path, json)->Belt.Result.flatMap(s =>
    switch Js.String2.toLowerCase(s) {
    | "blocking" => Ok(Blocking)
    | "high" => Ok(High)
    | "medium" => Ok(Medium)
    | "low" => Ok(Low)
    | "info" => Ok(Info)
    | other => Error(`${path}: unknown severity '${other}'`)
    }
  )

let decodePriority = (path: string, json: Js.Json.t): result<priority, string> =>
  asString(path, json)->Belt.Result.flatMap(s =>
    switch Js.String2.toLowerCase(s) {
    | "high" => Ok(PriorityHigh)
    | "medium" => Ok(PriorityMedium)
    | "low" => Ok(PriorityLow)
    | other => Error(`${path}: unknown priority '${other}'`)
    }
  )

let decodeLocation = (path: string, json: Js.Json.t): result<codeLocation, string> =>
  asObject(path, json)->Belt.Result.flatMap(obj => {
    let file = decodeStringField(obj, path, "file")
    let line = decodeField(obj, "line")->Belt.Result.flatMap(v => asInt(`${path}.line`, v))
    let column = switch decodeOptField(obj, "column") {
    | Some(v) => asInt(`${path}.column`, v)->Belt.Result.map(i => Some(i))
    | None => Ok(None)
    }
    switch (file, line, column) {
    | (Ok(f), Ok(l), Ok(c)) => Ok({file: f, line: l, column: c})
    | (Error(e), _, _) | (_, Error(e), _) | (_, _, Error(e)) => Error(e)
    }
  })

let decodeViolation = (path: string, json: Js.Json.t): result<policyViolation, string> =>
  asObject(path, json)->Belt.Result.flatMap(obj => {
    let entityId = decodeStringField(obj, path, "entityId")
    let policy = decodeStringField(obj, path, "policy")
    let severity =
      decodeField(obj, "severity")->Belt.Result.flatMap(v =>
        decodeSeverity(`${path}.severity`, v)
      )
    let message = decodeStringField(obj, path, "message")
    let location = switch decodeOptField(obj, "location") {
    | Some(v) => decodeLocation(`${path}.location`, v)->Belt.Result.map(l => Some(l))
    | None => Ok(None)
    }
    let suggestions = switch decodeOptField(obj, "suggestions") {
    | Some(v) =>
      asArray(`${path}.suggestions`, v)->Belt.Result.flatMap(arr =>
        mapArray(arr, asString, `${path}.suggestions`)
      )
    | None => Ok([])
    }
    switch (entityId, policy, severity, message, location, suggestions) {
    | (Ok(e), Ok(p), Ok(sev), Ok(m), Ok(l), Ok(s)) =>
      Ok({entityId: e, policy: p, severity: sev, message: m, location: l, suggestions: s})
    | (Error(e), _, _, _, _, _)
    | (_, Error(e), _, _, _, _)
    | (_, _, Error(e), _, _, _)
    | (_, _, _, Error(e), _, _)
    | (_, _, _, _, Error(e), _)
    | (_, _, _, _, _, Error(e)) =>
      Error(e)
    }
  })

let decodeExpectedImprovement = (
  path: string,
  json: Js.Json.t,
): result<Js.Dict.t<float>, string> =>
  asObject(path, json)->Belt.Result.flatMap(obj => {
    let out = Js.Dict.empty()
    let err = ref(None)
    Js.Dict.keys(obj)->Belt.Array.forEach(k => {
      if err.contents == None {
        switch Js.Dict.get(obj, k) {
        | Some(v) =>
          switch asFloat(`${path}.${k}`, v) {
          | Ok(n) => Js.Dict.set(out, k, n)
          | Error(e) => err := Some(e)
          }
        | None => ()
        }
      }
    })
    switch err.contents {
    | Some(e) => Error(e)
    | None => Ok(out)
    }
  })

let decodeRecommendation = (path: string, json: Js.Json.t): result<recommendation, string> =>
  asObject(path, json)->Belt.Result.flatMap(obj => {
    let entityId = decodeStringField(obj, path, "entityId")
    let action = decodeStringField(obj, path, "action")
    let reason = decodeStringField(obj, path, "reason")
    let priority =
      decodeField(obj, "priority")->Belt.Result.flatMap(v =>
        decodePriority(`${path}.priority`, v)
      )
    let confidence = decodeFloatField(obj, path, "confidence")
    let expectedImprovement = switch decodeOptField(obj, "expectedImprovement") {
    | Some(v) => decodeExpectedImprovement(`${path}.expectedImprovement`, v)
    | None => Ok(Js.Dict.empty())
    }
    switch (entityId, action, reason, priority, confidence, expectedImprovement) {
    | (Ok(e), Ok(a), Ok(r), Ok(p), Ok(c), Ok(ei)) =>
      Ok({
        entityId: e,
        action: a,
        reason: r,
        priority: p,
        confidence: c,
        expectedImprovement: ei,
      })
    | (Error(e), _, _, _, _, _)
    | (_, Error(e), _, _, _, _)
    | (_, _, Error(e), _, _, _)
    | (_, _, _, Error(e), _, _)
    | (_, _, _, _, Error(e), _)
    | (_, _, _, _, _, Error(e)) =>
      Error(e)
    }
  })

let decodeAnalysisResult = (json: Js.Json.t): result<analysisResult, string> =>
  asObject("$", json)->Belt.Result.flatMap(obj => {
    let eco =
      decodeField(obj, "eco")->Belt.Result.flatMap(v => decodeEcoMetrics("$.eco", v))
    let econ =
      decodeField(obj, "econ")->Belt.Result.flatMap(v => decodeEconMetrics("$.econ", v))
    let quality =
      decodeField(obj, "quality")->Belt.Result.flatMap(v =>
        decodeQualityMetrics("$.quality", v)
      )
    let health =
      decodeField(obj, "health")->Belt.Result.flatMap(v => decodeHealthIndex("$.health", v))
    let violations = switch decodeOptField(obj, "violations") {
    | Some(v) =>
      asArray("$.violations", v)->Belt.Result.flatMap(arr =>
        mapArray(arr, decodeViolation, "$.violations")
      )
    | None => Ok([])
    }
    let recommendations = switch decodeOptField(obj, "recommendations") {
    | Some(v) =>
      asArray("$.recommendations", v)->Belt.Result.flatMap(arr =>
        mapArray(arr, decodeRecommendation, "$.recommendations")
      )
    | None => Ok([])
    }
    let timestamp = decodeStringField(obj, "$", "timestamp")
    let commitSha = switch decodeOptField(obj, "commitSha") {
    | Some(v) => asString("$.commitSha", v)->Belt.Result.map(s => Some(s))
    | None => Ok(None)
    }
    switch (eco, econ, quality, health, violations, recommendations, timestamp, commitSha) {
    | (Ok(e), Ok(ec), Ok(q), Ok(h), Ok(v), Ok(r), Ok(t), Ok(c)) =>
      Ok({
        eco: e,
        econ: ec,
        quality: q,
        health: h,
        violations: v,
        recommendations: r,
        timestamp: t,
        commitSha: c,
      })
    | (Error(e), _, _, _, _, _, _, _)
    | (_, Error(e), _, _, _, _, _, _)
    | (_, _, Error(e), _, _, _, _, _)
    | (_, _, _, Error(e), _, _, _, _)
    | (_, _, _, _, Error(e), _, _, _)
    | (_, _, _, _, _, Error(e), _, _)
    | (_, _, _, _, _, _, Error(e), _)
    | (_, _, _, _, _, _, _, Error(e)) =>
      Error(e)
    }
  })

// -----------------------------------------------------------------------------
// HTTP clients
// -----------------------------------------------------------------------------

let analyzeRepository = async (endpoint: string, repoUrl: string, ref: string): result<
  analysisResult,
  string,
> => {
  let body = Js.Json.object_(
    Js.Dict.fromArray([("url", Js.Json.string(repoUrl)), ("ref", Js.Json.string(ref))]),
  )

  try {
    let response = await Fetch.fetch(
      `${endpoint}/repository`,
      {
        "method": "POST",
        "headers": {"Content-Type": "application/json"},
        "body": Js.Json.stringify(body),
      },
    )

    if Fetch.Response.ok(response) {
      let json = await Fetch.Response.json(response)
      decodeAnalysisResult(json)
    } else {
      Error(`Analysis failed: ${Fetch.Response.statusText(response)}`)
    }
  } catch {
  | Js.Exn.Error(e) =>
    Error(`Analysis request failed: ${Js.Exn.message(e)->Belt.Option.getWithDefault("unknown")}`)
  }
}

let analyzeDiff = async (
  endpoint: string,
  repoUrl: string,
  base: string,
  head: string,
): result<analysisResult, string> => {
  let body = Js.Json.object_(
    Js.Dict.fromArray([
      ("url", Js.Json.string(repoUrl)),
      ("base", Js.Json.string(base)),
      ("head", Js.Json.string(head)),
    ]),
  )

  try {
    let response = await Fetch.fetch(
      `${endpoint}/diff`,
      {
        "method": "POST",
        "headers": {"Content-Type": "application/json"},
        "body": Js.Json.stringify(body),
      },
    )

    if Fetch.Response.ok(response) {
      let json = await Fetch.Response.json(response)
      decodeAnalysisResult(json)
    } else {
      Error(`Diff analysis failed: ${Fetch.Response.statusText(response)}`)
    }
  } catch {
  | Js.Exn.Error(e) =>
    Error(`Analysis request failed: ${Js.Exn.message(e)->Belt.Option.getWithDefault("unknown")}`)
  }
}

// Mock analysis — for tests and local development ONLY.
// MUST NOT be substituted for real analyser output in production paths.
let mockAnalysis = (): analysisResult => {
  {
    eco: {
      carbonScore: 72.0,
      energyScore: 68.0,
      resourceScore: 75.0,
      score: 71.5,
    },
    econ: {
      paretoDistance: 0.15,
      allocationScore: 80.0,
      debtScore: 65.0,
      score: 72.0,
      paretoStatus: Some({
        isOptimal: false,
        distance: 0.15,
        improvements: Some(["Reduce complexity in src/utils.rs", "Add memoization to hot path"]),
      }),
    },
    quality: {
      complexityScore: 70.0,
      couplingScore: 75.0,
      coverageScore: 82.0,
      score: 75.5,
    },
    health: {
      eco: 0.4,
      econ: 0.3,
      quality: 0.3,
      total: 72.8,
      grade: "C",
    },
    violations: [],
    recommendations: [
      {
        entityId: "src/processing.rs",
        action: "optimize_loop",
        reason: "Hot loop could benefit from vectorization",
        priority: PriorityMedium,
        confidence: 0.78,
        expectedImprovement: Js.Dict.fromArray([("carbonScore", 5.0), ("energyScore", 8.0)]),
      },
    ],
    timestamp: "2024-12-08T10:00:00Z",
    commitSha: Some("abc123"),
  }
}
