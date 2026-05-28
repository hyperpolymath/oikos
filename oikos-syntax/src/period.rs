// SPDX-License-Identifier: MPL-2.0
// SPDX-FileCopyrightText: 2026 Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>

//! Fiscal period declarations.
//!
//! A fiscal period is the Oikos analogue of a Tofte–Talpin region in Ephapax.
//! Values created within a period are scoped to it; moving a value across a
//! period boundary requires an explicit `close` operation that transfers
//! ownership and records the end-of-period balance.
//!
//! This enforces the SFC discipline that stocks are measured at period-end
//! and flows are measured over the period: you cannot mix values from
//! different periods without making the temporal arithmetic explicit.

use serde::{Deserialize, Serialize};
use smol_str::SmolStr;

use crate::span::Span;

/// A fiscal period declaration.
///
/// Surface syntax:
///
/// ```text
/// period FY2025 : FiscalYear from 2025-04-01 to 2026-03-31
/// period Q1_2026 : Quarter    from 2026-01-01 to 2026-03-31
/// ```
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct PeriodDecl {
    /// Identifier used to qualify account values (e.g. `deposits@FY2025`).
    pub name: SmolStr,
    /// Period granularity hint (informational; does not affect type checking).
    pub kind: PeriodKind,
    /// ISO 8601 start date (inclusive).
    pub from: SmolStr,
    /// ISO 8601 end date (inclusive).
    pub to: SmolStr,
    /// Optional parent period for nesting (e.g. Q1 within FY).
    pub parent: Option<SmolStr>,
    pub span: Span,
}

/// The granularity of a fiscal period.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum PeriodKind {
    FiscalYear,
    HalfYear,
    Quarter,
    Month,
    Week,
    /// An ad-hoc period with an arbitrary date range.
    Custom,
}
