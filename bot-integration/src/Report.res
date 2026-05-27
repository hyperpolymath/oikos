// Report generation for PR comments and SARIF output

open Types

let getGrade = (score: float): string => {
  if score >= 90.0 {
    "A"
  } else if score >= 80.0 {
    "B"
  } else if score >= 70.0 {
    "C"
  } else if score >= 60.0 {
    "D"
  } else {
    "F"
  }
}

let getGradeEmoji = (grade: string): string => {
  switch grade {
  | "A" => "🏆"
  | "B" => "✨"
  | "C" => "👍"
  | "D" => "⚠️"
  | _ => "🚨"
  }
}

let getStatusEmoji = (score: float): string => {
  if score >= 70.0 {
    "✅"
  } else if score >= 50.0 {
    "⚠️"
  } else {
    "❌"
  }
}

let severityToString = (s: severity): string => {
  switch s {
  | Blocking => "blocking"
  | High => "high"
  | Medium => "medium"
  | Low => "low"
  | Info => "info"
  }
}

let generatePRComment = (analysis: analysisResult, mode: botMode): string => {
  let grade = getGrade(analysis.health.total)
  let gradeEmoji = getGradeEmoji(grade)

  let header = `## 🏛️ Oikos Analysis\n\n`

  let healthLine = `### Overall Health: ${gradeEmoji} ${grade} (${Belt.Float.toString(
      analysis.health.total,
    )}/100)\n\n`

  let scoreTable =
    `| Metric | Score | Status |\n` ++
    `|--------|-------|--------|\n` ++
    `| 🌍 Ecological | ${Belt.Float.toString(analysis.eco.score)} | ${getStatusEmoji(
        analysis.eco.score,
      )} |\n` ++
    `| 📊 Economic | ${Belt.Float.toString(analysis.econ.score)} | ${getStatusEmoji(
        analysis.econ.score,
      )} |\n` ++
    `| ⚙️ Quality | ${Belt.Float.toString(analysis.quality.score)} | ${getStatusEmoji(
        analysis.quality.score,
      )} |\n\n`

  // Violations section
  let violationsSection = if Belt.Array.length(analysis.violations) > 0 {
    let violationLines =
      analysis.violations
      ->Belt.Array.map(v => {
        let icon = v.severity == Blocking ? "🚫" : "⚠️"
        `${icon} **${v.policy}**: ${v.message}\n`
      })
      ->Belt.Array.joinWith("", s => s)

    `### ⚠️ Policy Violations\n\n${violationLines}\n`
  } else {
    ""
  }

  // Recommendations section (limited by mode)
  let recommendationsSection = if Belt.Array.length(analysis.recommendations) > 0 && mode != Regulator {
    let maxRecs = mode == Consultant ? 10 : 5
    let topRecs = Belt.Array.slice(analysis.recommendations, ~offset=0, ~len=maxRecs)

    let recLines =
      topRecs
      ->Belt.Array.map(r => {
        let confidence = Belt.Float.toInt(r.confidence *. 100.0)
        `- **${r.action}** (${Belt.Int.toString(confidence)}% confidence): ${r.reason}\n`
      })
      ->Belt.Array.joinWith("", s => s)

    `### 💡 Recommendations\n\n${recLines}\n`
  } else {
    ""
  }

  // Pareto section
  let paretoSection = switch analysis.econ.paretoStatus {
  | Some(ps) =>
    let status = if ps.isOptimal {
      `✅ This code is on the Pareto frontier - no dominated trade-offs detected.\n\n`
    } else {
      let improvements = switch ps.improvements {
      | Some(imps) =>
        imps->Belt.Array.map(i => `- ${i}\n`)->Belt.Array.joinWith("", s => s)
      | None => ""
      }
      `📍 Distance from Pareto frontier: ${Belt.Float.toString(ps.distance)}\n\n` ++
      (improvements != "" ? `Potential Pareto improvements:\n${improvements}\n` : "")
    }
    `### 📈 Pareto Analysis\n\n${status}`
  | None => ""
  }

  // Footer
  let footer =
    `---\n` ++
    `*Analyzed by [Oikos Bot](https://github.com/hyperpolymath/oikos-bot) | ` ++
    `Mode: ${Config.modeToString(mode)} | ` ++
    `[Learn more about eco-friendly coding](https://greensoftware.foundation/)*\n`

  header ++ healthLine ++ scoreTable ++ violationsSection ++ recommendationsSection ++ paretoSection ++ footer
}

// Posted when the analyser is unavailable. Honest about the failure;
// never fabricates scores — see fix/bot-hardening-fail-closed for why.
let generateDegradedComment = (reason: string, mode: botMode): string => {
  let header = `## 🏛️ Oikos Analysis — unavailable\n\n`
  let body =
    `The analyser could not be reached for this PR, so no eco/econ/quality scores were produced.\n\n` ++
    `> Reason: ${reason}\n\n`
  let modeNote = switch mode {
  | Regulator =>
    `**Regulator mode**: this PR will not be auto-approved by Oikos until analysis completes successfully. The maintainer should re-run the bot or merge manually with explicit acknowledgement.\n\n`
  | _ => `Re-run the bot once the analyser is healthy to get a real report.\n\n`
  }
  let footer =
    `---\n` ++
    `*[Oikos Bot](https://github.com/hyperpolymath/oikos) | Mode: ${Config.modeToString(mode)} | Status: degraded*\n`
  header ++ body ++ modeNote ++ footer
}

// Generate SARIF for code scanning integration
let generateSARIF = (analysis: analysisResult): Js.Json.t => {
  let rules = [
    Js.Dict.fromArray([
      ("id", Js.Json.string("eco/eco-minimum")),
      ("name", Js.Json.string("EcoMinimum")),
      (
        "shortDescription",
        Js.Json.object_(
          Js.Dict.fromArray([("text", Js.Json.string("Eco minimum threshold not met"))]),
        ),
      ),
    ]),
    Js.Dict.fromArray([
      ("id", Js.Json.string("eco/eco-standard")),
      ("name", Js.Json.string("EcoStandard")),
      (
        "shortDescription",
        Js.Json.object_(
          Js.Dict.fromArray([("text", Js.Json.string("Eco standard threshold not met"))]),
        ),
      ),
    ]),
  ]

  let results =
    analysis.violations->Belt.Array.map(v => {
      Js.Dict.fromArray([
        ("ruleId", Js.Json.string(`eco/${Js.String.replace("_", "-", v.policy)}`)),
        ("level", Js.Json.string(v.severity == Blocking ? "error" : "warning")),
        (
          "message",
          Js.Json.object_(Js.Dict.fromArray([("text", Js.Json.string(v.message))])),
        ),
      ])
    })

  Js.Json.object_(
    Js.Dict.fromArray([
      (
        "$schema",
        Js.Json.string(
          "https://raw.githubusercontent.com/oasis-tcs/sarif-spec/master/Schemata/sarif-schema-2.1.0.json",
        ),
      ),
      ("version", Js.Json.string("2.1.0")),
      (
        "runs",
        Js.Json.array([
          Js.Json.object_(
            Js.Dict.fromArray([
              (
                "tool",
                Js.Json.object_(
                  Js.Dict.fromArray([
                    (
                      "driver",
                      Js.Json.object_(
                        Js.Dict.fromArray([
                          ("name", Js.Json.string("oikos-bot")),
                          ("version", Js.Json.string("0.1.0-beta")),
                          (
                            "informationUri",
                            Js.Json.string("https://github.com/hyperpolymath/oikos-bot"),
                          ),
                          ("rules", Js.Json.array(rules->Belt.Array.map(Js.Json.object_))),
                        ]),
                      ),
                    ),
                  ]),
                ),
              ),
              ("results", Js.Json.array(results->Belt.Array.map(Js.Json.object_))),
            ]),
          ),
        ]),
      ),
    ]),
  )
}
