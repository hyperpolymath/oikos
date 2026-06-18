// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
// SPDX-FileCopyrightText: 2026 Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>

//! Sector declarations and balance-sheet structure.
//!
//! A **sector** represents an economic agent or institutional unit
//! (e.g. households, commercial banks, central government).  Each sector
//! has a balance sheet: a set of assets and liabilities that must satisfy
//! the Godley accounting identity at every period boundary.

use serde::{Deserialize, Serialize};
use smol_str::SmolStr;

use crate::account::AccountDecl;
use crate::span::Span;

/// A reference to an account defined elsewhere in the model.
#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub struct AccountRef {
    pub name: SmolStr,
    pub span: Span,
}

/// A sector declaration.
///
/// Surface syntax:
///
/// ```text
/// sector Households {
///     asset     deposits
///     asset     equities
///     liability mortgage
///     liability consumer_credit
/// }
/// ```
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct SectorDecl {
    /// Sector name as used in the Godley matrix column headers.
    pub name: SmolStr,
    /// Accounts local to this sector (may shadow model-level accounts).
    pub accounts: Vec<AccountDecl>,
    /// Accounts held as assets on this sector's balance sheet.
    pub assets: Vec<AccountRef>,
    /// Accounts held as liabilities on this sector's balance sheet.
    pub liabilities: Vec<AccountRef>,
    /// Optional prose description.
    pub description: Option<SmolStr>,
    pub span: Span,
}
