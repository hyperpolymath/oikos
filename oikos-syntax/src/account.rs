// SPDX-License-Identifier: MPL-2.0
// SPDX-FileCopyrightText: 2026 Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>

//! Stock and flow account declarations.
//!
//! A **stock** is a quantity measured at a point in time (e.g. bank deposits).
//! A **flow** is a quantity measured over a period (e.g. wages, taxes).
//! The two types are distinct: adding a stock to a flow without an explicit
//! integration step is a type error.  This mirrors the physical distinction
//! between a reservoir (stock) and a pipe (flow).

use serde::{Deserialize, Serialize};
use smol_str::SmolStr;

use crate::dimension::CurrencyCode;
use crate::span::Span;

/// Whether an account holds a stock or a flow value.
///
/// This becomes a phantom-type distinction in the Ephapax IR.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum AccountKind {
    /// Accumulated balance measured at a point in time.
    Stock,
    /// Rate of change measured over a fiscal period.
    Flow,
}

/// An account declaration within a sector or model.
///
/// Surface syntax examples:
///
/// ```text
/// account deposits : Stock GBP
/// account wages    : Flow  GBP
/// ```
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct AccountDecl {
    /// Account identifier used elsewhere in the model.
    pub name: SmolStr,
    /// Whether this is a stock or a flow account.
    pub kind: AccountKind,
    /// The currency dimension of this account's values.
    pub currency: CurrencyCode,
    /// Optional human-readable description.
    pub description: Option<SmolStr>,
    pub span: Span,
}
