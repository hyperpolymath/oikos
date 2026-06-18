<!--
SPDX-License-Identifier: MPL-2.0
Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
-->
# Security Policy
*SustainaBot* adheres to **Rhodium Standard Repo (RSR)** principles, emphasizing **reversibility, attestation, and minimal attack surfaces**.

---

## Supported Versions
| Version | Supported          | Notes                                  |
|---------|--------------------|----------------------------------------|
| 0.x.x   | :white_check_mark: | Only the **latest minor version** receives security updates. |

> **Note**: SustainaBot is in **early development**. Security updates are prioritized for the latest release.

---

## Reporting a Vulnerability
**Do not report vulnerabilities publicly** (e.g., GitHub/GitLab Issues).
Instead, use one of these **private channels**:

1. **GitLab Security Advisories**:
   [Report a vulnerability](https://gitlab.com/hyperpolymath/scarcity-bot/-/security/advisories/new)
   *(Preferred for traceability and RSR compliance.)*

2. **Email**:
   `security@hyperpolymath.org` (PGP: `0xYOUR_ED448_KEY`)
   *(For urgent or sensitive disclosures.)*

---

### What to Include
Provide **detailed, actionable information**:
- **Type of issue**:
  - Example: Buffer overflow, XSS, supply chain tampering, or **waste metric spoofing**.
- **Affected components**:
  - Source file paths (e.g., `lib/audit/exec.rb`).
  - **Commit hash/tag/branch** or direct URL.
- **Reproduction steps**:
  - Command-line invocations, config snippets, or **Justfile recipes** used.
- **Impact**:
  - How could an attacker exploit this? (e.g., "Fake carbon savings reports," "CI/CD pipeline hijacking.")
- **Proof-of-Concept**:
  - Code snippets or **SHAKE256 hashes** of malicious inputs (if applicable).

---

## Response Timeline
| Phase               | Target          | Notes                                  |
|---------------------|-----------------|----------------------------------------|
| **Initial Response** | ≤48 hours       | Acknowledges receipt.                  |
| **Status Update**   | ≤7 days         | Progress or mitigation advice.         |
| **Resolution**      | ≤30 days        | For **critical issues** (e.g., RCE, data leaks). |
| **Attestation**     | Post-resolution | Logs signed with **Ed448** in `logs/`. |

---

## Security Considerations

### Data Handling
SustainaBot processes:
- **Source code** (for waste analysis).
- **Dependency graphs** (economic/ecological impact).
- **CI/CD configurations** (e.g., GitLab pipelines).
- **VoID/Dublin Core metadata** (interoperability with WordPress/Drupal).

**Guiding Principles**:
- **Minimal Retention**: Data deleted post-audit unless **explicitly logged for reversibility**.
- **Hashing**: All logs use **SHAKE256/Ed448** (see `logs/README.md`).
- **BOINC Distributed Audits**:
  - Nodes **never store raw repo data**; only **hashed waste metrics** are shared.
- **Cloud Backups**:
  - Metadata backed up to **Dropbox/OneDrive/Syncthing/iDrive** (per Memory #3).
  - Full backups stored on **RAID 10 + Acronis** (per Memory #4).

### Integration Security
- **Environment Variables**:
  ```bash
  # Example: .env
  SCARCITY_API_KEY="x"  # Never commit this!
  GITHUB_TOKEN="y"      # Use GitLab CI variables or encrypted secrets.
