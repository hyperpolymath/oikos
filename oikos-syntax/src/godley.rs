// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
// SPDX-FileCopyrightText: 2026 Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>

//! Godley matrix — the global accounting identity.
//!
//! The Godley–Lavoie transactions matrix is the central invariant of every SFC
//! model.  Each row is an account; each column is a sector.  The sign
//! convention is asset-positive: a `+` in a cell means the sector's balance in
//! that account increases, a `-` means it decreases.
//!
//! The type-checking rule: **every column must sum to zero**.  If any sector
//! can end a period with non-zero net financial wealth created from nothing, the
//! model has violated double-entry bookkeeping and must not compile.
//!
//! Oikos encodes this as a structural check over the [`GodleyMatrix`] node
//! before desugaring: the checker inspects sign polarities and verifies that
//! for every account row the signs across all columns cancel.

use serde::{Deserialize, Serialize};
use smol_str::SmolStr;

use crate::sector::AccountRef;
use crate::span::Span;

/// The sign of a Godley matrix entry.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum GodleySign {
    /// Positive entry: the sector's balance increases.
    Plus,
    /// Negative entry: the sector's balance decreases.
    Minus,
    /// Empty cell: this sector does not participate in this account.
    Zero,
}

/// A single cell in the Godley matrix.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct GodleyCell {
    /// The account this cell belongs to (row axis).
    pub account: AccountRef,
    /// The sector this cell belongs to (column axis).
    pub sector: SmolStr,
    /// The sign of this entry.
    pub sign: GodleySign,
    pub span: Span,
}

/// The complete Godley transactions matrix for a model.
///
/// Surface syntax — the matrix is written as a pipe-delimited table,
/// matching the presentation in Godley & Lavoie (2007):
///
/// ```text
/// godley {
///     | Account          | Households | CommBanks | CentralBank |
///     | deposits         | +          | -         |             |
///     | advances         |            | +         | -           |
///     | government_bills | +          |           | -           |
/// }
/// ```
///
/// The compiler checks that each column sums to zero.  An imbalance is a
/// hard type error, not a warning.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct GodleyMatrix {
    /// All cells, in source order.  The checker reconstructs rows and columns.
    pub cells: Vec<GodleyCell>,
    /// Column headers (sector names), in declaration order.
    pub sectors: Vec<SmolStr>,
    /// Row headers (account names), in declaration order.
    pub accounts: Vec<AccountRef>,
    pub span: Span,
}
