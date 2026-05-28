// SPDX-License-Identifier: MPL-2.0-or-later
// SPDX-FileCopyrightText: 2024-2025 hyperpolymath

# Oikos Bot: Ecological & Economic Code Analysis Platform

> **Note — which product is this?**
> This document describes **OikosBot**, the code-analysis GitHub/GitLab App.
> Its AffineScript port lives in
> [`bot-integration-affine/`](bot-integration-affine/) (in-flight; the
> previous ReScript codebase at `bot-integration/` was retired on
> 2026-05-28 — see git history for the prior implementation).
> The DSL of the same root name (a typed compiler for stock-flow consistent
> macroeconomic models) is documented in [`README.adoc`](README.adoc) and
> [`docs/DESIGN.adoc`](docs/DESIGN.adoc).
> They share the οἶκος root but are otherwise unrelated.
> See [`docs/disambiguation/oikos-dsl-vs-oikosbot.adoc`](docs/disambiguation/oikos-dsl-vs-oikosbot.adoc).

## Vision

Oikos Bot is an intelligent code analysis platform that acts as a **consultant, advisor, regulator, and policy developer** for software repositories. It **complements** existing tools like Dependabot, CodeQL, and Copilot by adding a dedicated **ecological and economic lens** to code analysis.

### Complementary, Not Competing

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    EXISTING ECOSYSTEM (Collaborate With)                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Dependabot          CodeQL           Copilot           Renovate            │
│  ───────────         ──────           ───────           ────────            │
│  Dependencies        Security         AI Assist         Updates             │
│       │                 │                │                  │               │
│       └─────────────────┼────────────────┼──────────────────┘               │
│                         ▼                ▼                                   │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                        SHARED CONTEXT LAYER                          │   │
│  │  - Common prompt templates for eco/econ awareness                    │   │
│  │  - Shared analysis results via APIs                                  │   │
│  │  - Unified reporting dashboard                                       │   │
│  │  - Cross-tool recommendations                                        │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    ▲                                        │
│                                    │                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                           OIKOS BOT                                  │   │
│  │  - Ecological analysis (carbon, energy, resources)                   │   │
│  │  - Economic optimization (Pareto, allocative efficiency)             │   │
│  │  - Quality metrics with eco/econ weighting                           │   │
│  │  - Policy development and learning                                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Key Integration Principles:**
1. **Additive Value**: Oikos Bot adds eco/econ analysis; doesn't duplicate security/dependency work
2. **Shared Prompts**: Provide prompt templates that Copilot/AI tools can use for eco-aware suggestions
3. **Data Exchange**: Consume and produce data in formats other tools understand
4. **Non-Blocking**: Advisory by default; teams opt-in to enforcement
5. **First-Class Thinking**: Make ecological/economic reasoning as natural as security/testing

## Core Philosophy

### Normative Framework

1. **Ecological Criteria**
   - Carbon intensity of code execution (SCI - Software Carbon Intensity)
   - Energy efficiency patterns
   - Resource utilization optimization
   - Sustainable computing practices

2. **Economic Criteria**
   - **Pareto Optimality**: No change can make one aspect better without making another worse
   - **Allocative Efficiency**: Resources allocated to maximize total value
   - Technical debt as economic liability
   - Opportunity cost of architectural decisions

3. **Quality Metrics**
   - Cyclomatic complexity
   - Coupling/cohesion analysis
   - Test coverage economics
   - Documentation completeness

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           OIKOS BOT PLATFORM                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐                 │
│  │   GitHub Bot   │  │  GitLab Bot    │  │   CLI Tool     │                 │
│  │   Integration  │  │  Integration   │  │   Interface    │                 │
│  └───────┬────────┘  └───────┬────────┘  └───────┬────────┘                 │
│          │                   │                   │                          │
│          └───────────────────┼───────────────────┘                          │
│                              ▼                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │                    ORCHESTRATION LAYER (Rust)                         │  │
│  │  - Request routing & scheduling                                       │  │
│  │  - Analysis pipeline coordination                                     │  │
│  │  - Result aggregation & reporting                                     │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                              │                                              │
│          ┌───────────────────┼───────────────────┐                          │
│          ▼                   ▼                   ▼                          │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐                 │
│  │    HASKELL     │  │     OCAML      │  │    PYTHON      │                 │
│  │  Code Analyzer │  │  Doc Analyzer  │  │  ML/DeepProb   │                 │
│  │                │  │                │  │                │                 │
│  │ - Type safety  │  │ - NLP parsing  │  │ - DeepProbLog  │                 │
│  │ - Purity check │  │ - Semantic     │  │ - Pattern      │                 │
│  │ - Complexity   │  │   extraction   │  │   learning     │                 │
│  │ - Energy est.  │  │ - Consistency  │  │ - Anomaly det. │                 │
│  └───────┬────────┘  └───────┬────────┘  └───────┬────────┘                 │
│          │                   │                   │                          │
│          └───────────────────┼───────────────────┘                          │
│                              ▼                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │                    POLICY ENGINE (Datalog + DeepProbLog)              │  │
│  │  - Rule inference & learning                                          │  │
│  │  - Policy generation from practice                                    │  │
│  │  - Probabilistic reasoning                                            │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                              │                                              │
│          ┌───────────────────┴───────────────────┐                          │
│          ▼                                       ▼                          │
│  ┌────────────────────────┐      ┌────────────────────────┐                │
│  │      ARANGODB          │      │      VIRTUOSO          │                │
│  │   (Graph + Document)   │◄────►│   (RDF + SPARQL)       │                │
│  │                        │      │                        │                │
│  │ - Code relationships   │      │ - Semantic knowledge   │                │
│  │ - Analysis history     │      │ - Ontologies           │                │
│  │ - Project metadata     │      │ - Linked data          │                │
│  └────────────────────────┘      └────────────────────────┘                │
│                              │                                              │
│                              ▼                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │                    ECHIDNA (Math Proofs/Solvers)                      │  │
│  │  gitlab.com/hyperpolymath/echidna                                     │  │
│  │  - Formal verification of optimality claims                           │  │
│  │  - Economic model validation                                          │  │
│  │  - Constraint satisfaction                                            │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Component Details

### 1. Haskell Code Analysis Engine (`/analyzers/code-haskell/`)

**Why Haskell?**
- Strong type system for reliable analysis
- Pure functions = predictable behavior
- Excellent for AST manipulation
- Pattern matching for code pattern detection

**Capabilities:**
```haskell
-- Core analysis types
data EcoAnalysis = EcoAnalysis
  { carbonIntensity    :: CarbonScore      -- Estimated CO2/execution
  , energyEfficiency   :: EnergyScore      -- Energy patterns
  , resourceAllocation :: AllocationScore  -- Memory/CPU efficiency
  , paretoFrontier     :: [ParetoPoint]    -- Optimal trade-offs
  }

data QualityAnalysis = QualityAnalysis
  { complexity        :: ComplexityMetrics
  , coupling          :: CouplingScore
  , technicalDebt     :: DebtEstimate
  , testCoverage      :: CoverageAnalysis
  }
```

**Analysis Modules:**
- `Eco.Carbon` - Carbon intensity estimation
- `Eco.Energy` - Energy pattern detection
- `Eco.Pareto` - Multi-objective optimization analysis
- `Quality.Complexity` - Cyclomatic/cognitive complexity
- `Quality.Coupling` - Dependency analysis
- `Quality.Debt` - Technical debt quantification

### 2. OCaml Documentation Analyzer (`/analyzers/docs-ocaml/`)

**Why OCaml?**
- Excellent for parsing and language processing
- Strong module system for separation of concerns
- Efficient compilation
- Good interop with formal methods tools

**Capabilities:**
```ocaml
(* Documentation analysis pipeline *)
type doc_analysis = {
  completeness: float;                    (* 0.0 - 1.0 *)
  consistency: consistency_report;        (* Internal consistency *)
  semantic_coverage: semantic_map;        (* Concept coverage *)
  readability: readability_scores;        (* Various readability metrics *)
  eco_alignment: eco_alignment_report;    (* Alignment with eco principles *)
}

(* Natural language processing for docs *)
module DocNLP : sig
  val extract_concepts : document -> concept list
  val check_consistency : document list -> inconsistency list
  val assess_completeness : document -> api_surface -> float
end
```

### 3. Policy Engine (Datalog + DeepProbLog)

**Architecture:**
```
┌─────────────────────────────────────────────────────────────┐
│                     POLICY ENGINE                            │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────────────┐         ┌─────────────────┐            │
│  │    DATALOG      │         │   DEEPPROBLOG   │            │
│  │   (Certainties) │◄───────►│  (Uncertainties)│            │
│  │                 │         │                 │            │
│  │ % Hard rules    │         │ % Learned rules │            │
│  │ efficient(X) :- │         │ nn(energy_net,  │            │
│  │   low_carbon(X),│         │   [Code],       │            │
│  │   fast(X).      │         │   Score) ::     │            │
│  │                 │         │   efficient(X). │            │
│  └─────────────────┘         └─────────────────┘            │
│           │                           │                      │
│           └───────────┬───────────────┘                      │
│                       ▼                                      │
│  ┌─────────────────────────────────────────────────────────┐│
│  │              PRAXIS FEEDBACK LOOP                        ││
│  │  Theory ──► Practice ──► Observation ──► Theory Update   ││
│  └─────────────────────────────────────────────────────────┘│
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

**Example Policies:**
```prolog
% Datalog: Deterministic rules
pareto_dominated(X, Y) :-
    all_metrics(X, MetricsX),
    all_metrics(Y, MetricsY),
    dominated_by(MetricsX, MetricsY).

needs_refactor(Component) :-
    technical_debt(Component, Debt),
    Debt > threshold(high),
    not(pareto_optimal(Component)).

% DeepProbLog: Probabilistic learned rules
nn(carbon_estimator, [CodeFeatures], CarbonScore) ::
    high_carbon(Code) :- CarbonScore > 0.7.

0.8 :: eco_friendly(Code) :-
    low_carbon(Code),
    efficient_memory(Code).
```

### 4. Twin Database Architecture

**ArangoDB (Graph + Document Store):**
- Code dependency graphs
- Analysis history and trends
- Project metadata
- Change tracking

**Virtuoso (RDF Triple Store):**
- Semantic knowledge base
- Software ontologies (e.g., SEON, CodeOntology)
- Linked open data integration
- SPARQL queries for complex reasoning

**Synchronization:**
```
ArangoDB                          Virtuoso
─────────                         ────────
{                                 <project:123>
  "_key": "123",          ──►       a :SoftwareProject ;
  "type": "project",                :hasName "oikos-bot" ;
  "metrics": {...}                  :hasCarbonScore "0.3"^^xsd:float .
}
```

### 5. Echidna Integration

Integration with `gitlab.com/hyperpolymath/echidna` for:
- Formal verification of Pareto optimality claims
- Mathematical proofs for efficiency bounds
- Constraint solving for resource allocation
- Economic model validation

## Bot Roles & Behaviors

### 1. Consultant Mode
- Answers questions about code efficiency
- Provides alternative implementations
- Explains trade-offs

### 2. Advisor Mode
- Proactive suggestions on PRs/commits
- Best practice recommendations
- Learning resource suggestions

### 3. Regulator Mode
- Enforces policy compliance
- Blocks PRs that violate eco-standards
- Generates compliance reports

### 4. Policy Developer Mode
- Learns from codebase patterns
- Generates new policies from practice
- Evolves rules based on outcomes

## Analysis Pipeline

```
1. TRIGGER
   └─► PR opened / Push / Schedule / Manual

2. FETCH
   └─► Clone/fetch repository content

3. PARSE
   ├─► Haskell: Parse code ASTs
   └─► OCaml: Parse documentation

4. ANALYZE
   ├─► Carbon intensity estimation
   ├─► Energy pattern detection
   ├─► Complexity metrics
   ├─► Pareto frontier calculation
   └─► Documentation completeness

5. REASON
   ├─► Datalog: Apply deterministic rules
   └─► DeepProbLog: Probabilistic inference

6. VERIFY (optional)
   └─► Echidna: Formal verification of claims

7. STORE
   ├─► ArangoDB: Store results & relationships
   └─► Virtuoso: Update semantic knowledge

8. REPORT
   ├─► Generate findings report
   ├─► Create PR comments
   ├─► Update dashboards
   └─► Suggest improvements

9. LEARN
   └─► Feed outcomes back to policy engine
```

## Metrics & Scoring

### Ecological Score (0-100)
```
EcoScore = w1*CarbonScore + w2*EnergyScore + w3*ResourceScore

Where:
- CarbonScore: Based on SCI specification (ISO/IEC 21031:2024)
- EnergyScore: Energy efficiency patterns
- ResourceScore: Memory/CPU utilization efficiency
```

### Economic Score (0-100)
```
EconScore = w1*ParetoScore + w2*AllocationScore + w3*DebtScore

Where:
- ParetoScore: Distance from Pareto frontier
- AllocationScore: Allocative efficiency measure
- DebtScore: Inverse of technical debt burden
```

### Quality Score (0-100)
```
QualityScore = w1*ComplexityScore + w2*CouplingScore + w3*CoverageScore
```

### Composite Health Index
```
HealthIndex = α*EcoScore + β*EconScore + γ*QualityScore

Default weights: α=0.4, β=0.3, γ=0.3
(Customizable per organization)
```

## Technology Stack Summary

| Component | Language | Purpose |
|-----------|----------|---------|
| Orchestrator | Rust | High-performance coordination |
| Code Analyzer | Haskell | AST analysis, type checking |
| Doc Analyzer | OCaml | NLP, semantic extraction |
| Policy Engine | Python + Datalog | Rule inference, ML |
| DeepProbLog | Python | Probabilistic logic learning |
| Bot Interface | ReScript + Deno | GitHub/GitLab integration |
| Graph DB | ArangoDB | Relationships, history |
| Triple Store | Virtuoso | Semantic knowledge |
| Math Proofs | Echidna (external) | Formal verification |

## Ecosystem Integrations

### GitHub/GitLab Native Integration

**GitHub Actions/Apps Integration:**
```yaml
# .github/workflows/oikos.yml
name: Oikos Analysis
on: [pull_request, push]

jobs:
  eco-analysis:
    runs-on: ubuntu-latest
    steps:
      - uses: hyperpolymath/oikos-bot-action@v1
        with:
          mode: advisor  # consultant | advisor | regulator
          eco-threshold: 60
          econ-threshold: 50

      # Oikos Bot results feed into other tools
      - uses: actions/upload-artifact@v3
        with:
          name: eco-analysis
          path: .oikos-bot/results.json
```

**Integration Points:**
- Dependabot: Oikos Bot can add eco-scores to dependency update PRs
- CodeQL: Share SARIF format results for unified security+eco view
- Copilot: Provide context via `.github/copilot-instructions.md`

### Copilot/AI Assistant Integration

**Shared Prompt Templates** (`/prompts/`):

Oikos Bot provides prompt templates that AI coding assistants can use:

```markdown
<!-- .github/copilot-instructions.md (auto-generated by oikos-bot) -->
## Ecological Code Guidelines

When writing or reviewing code in this repository, consider:

1. **Carbon Efficiency**: Prefer algorithms with lower computational complexity
2. **Energy Patterns**: Avoid busy-waiting, prefer event-driven designs
3. **Resource Allocation**: Release resources promptly, use pooling
4. **Pareto Optimality**: When making trade-offs, document the decision

Current repo eco-score: 72/100
Areas needing attention: Memory allocation in /src/processing/*
```

### Data Exchange Formats

**SARIF Extension for Eco-Metrics:**
```json
{
  "$schema": "https://raw.githubusercontent.com/oasis-tcs/sarif-spec/master/Schemata/sarif-schema-2.1.0.json",
  "runs": [{
    "tool": {
      "driver": {
        "name": "oikos-bot",
        "version": "1.0.0",
        "informationUri": "https://oikos-bot.dev"
      }
    },
    "results": [{
      "ruleId": "eco/high-carbon-loop",
      "message": { "text": "Loop has O(n³) complexity, consider optimization" },
      "properties": {
        "ecoScore": 35,
        "carbonEstimate": "high",
        "paretoStatus": "dominated",
        "alternatives": ["Use memoization", "Consider parallel processing"]
      }
    }]
  }]
}
```

**OpenTelemetry Integration:**
```
oikos_bot_analysis_score{type="ecological",repo="myrepo"} 72
oikos_bot_analysis_score{type="economic",repo="myrepo"} 68
oikos_bot_carbon_intensity{repo="myrepo"} 0.34
oikos_bot_pareto_distance{repo="myrepo"} 0.12
```

### Cross-Tool Workflows

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    INTEGRATED ANALYSIS WORKFLOW                          │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  PR Opened                                                               │
│      │                                                                   │
│      ├──► Dependabot: Check dependencies ────────────────┐              │
│      │         │                                          │              │
│      │         └──► Oikos Bot: Score eco-impact ◄────────┤              │
│      │                   of new dependencies              │              │
│      │                                                    │              │
│      ├──► CodeQL: Security scan ─────────────────────────┤              │
│      │         │                                          │              │
│      │         └──► Oikos Bot: Security + Eco ◄──────────┤              │
│      │                   combined risk score              │              │
│      │                                                    │              │
│      ├──► Copilot: Review suggestions ───────────────────┤              │
│      │         │                                          │              │
│      │         └──► Oikos Bot: Enhance suggestions ◄─────┤              │
│      │                   with eco/econ context            │              │
│      │                                                    ▼              │
│      │                                          ┌─────────────────┐     │
│      └──────────────────────────────────────────► UNIFIED REPORT  │     │
│                                                  └─────────────────┘     │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### Praxis Loop: Theory ↔ Practice

```
                    ┌─────────────────────────────────────┐
                    │         PRAXIS FEEDBACK LOOP         │
                    └─────────────────────────────────────┘
                                     │
        ┌────────────────────────────┼────────────────────────────┐
        ▼                            ▼                            ▼
  ┌───────────┐              ┌───────────┐              ┌───────────┐
  │  THEORY   │              │ PRACTICE  │              │ LEARNING  │
  │           │              │           │              │           │
  │ Economic  │──────────────► Code      │──────────────► Observe   │
  │ models    │  Apply to     │ changes   │  Measure      │ outcomes  │
  │ Eco rules │  real code    │ PRs       │  results      │ patterns  │
  │           │              │           │              │           │
  └─────┬─────┘              └───────────┘              └─────┬─────┘
        │                                                      │
        │                    ┌───────────┐                    │
        │                    │  UPDATE   │                    │
        └────────────────────│  THEORY   │◄───────────────────┘
                             │           │
                             │ DeepProb- │
                             │ Log learns│
                             │ new rules │
                             └───────────┘
```

**Knowledge Sync Between Databases:**
```
ArangoDB (Operational)          Virtuoso (Semantic)
─────────────────────          ──────────────────────

Project metrics      ───────►  RDF triples for
Change history       ◄───────  reasoning
Analysis results               SPARQL queries
                               Ontology updates

         │                              │
         └──────────┬───────────────────┘
                    ▼
            ┌───────────────┐
            │   ECHIDNA     │
            │  (Proofs)     │
            │               │
            │ Verify claims │
            │ Solve optim.  │
            └───────────────┘
```

## References

- [Green Software Foundation](https://greensoftware.foundation/)
- [Software Carbon Intensity Spec](https://sci.greensoftware.foundation/)
- [DeepProbLog](https://github.com/ML-KULeuven/deepproblog)
- [Pareto Efficiency in Software](https://patrickkarsh.medium.com/pareto-efficiency-a-guide-for-software-engineers-3de566e58b75)
- [SARIF Specification](https://docs.oasis-open.org/sarif/sarif/v2.1.0/sarif-v2.1.0.html)
- [Green Software Foundation Awesome List](https://github.com/Green-Software-Foundation/awesome-green-software)
