// SPDX-License-Identifier: MPL-2.0
// SPDX-FileCopyrightText: 2026 Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>

//! Monetary dimension nodes.
//!
//! In SFC models every monetary quantity carries a currency dimension.
//! Adding GBP to USD is a type error; conversion requires an explicit dated
//! exchange rate.  These AST nodes represent dimension annotations before
//! elaboration into Ephapax phantom-type parameters.

use serde::{Deserialize, Serialize};
use smol_str::SmolStr;

use crate::span::Span;

/// An ISO 4217 currency code as it appears in source text (e.g. `GBP`, `USD`).
///
/// The type checker validates that the code is a known currency symbol;
/// the parser accepts any three-letter uppercase identifier here and defers
/// that validation to avoid coupling the parser to a currency list.
#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub struct CurrencyCode {
    /// The raw code text, e.g. `"GBP"`.
    pub code: SmolStr,
    pub span: Span,
}

/// A monetary literal: a decimal amount paired with a currency dimension.
///
/// Example surface syntax: `2_500.00 GBP`
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct MoneyLiteral {
    /// The numeric amount.  Stored as a string to preserve decimal precision
    /// without committing to a representation before the type checker runs.
    pub amount: SmolStr,
    /// The currency dimension of this literal.
    pub currency: CurrencyCode,
    pub span: Span,
}

/// A foreign-exchange rate used to convert between two currency dimensions.
///
/// FX conversion is never implicit; every cross-currency operation must
/// cite a dated rate.  Example surface syntax:
///
/// ```text
/// rate GBP_USD_2025Q4 : FxRate(GBP → USD) = 1.2650 on 2025-12-31
/// ```
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct FxRate {
    /// Identifier for this rate (used at call sites).
    pub name: SmolStr,
    /// The source currency dimension.
    pub from: CurrencyCode,
    /// The target currency dimension.
    pub to: CurrencyCode,
    /// Rate value, stored as a string for decimal precision.
    pub rate: SmolStr,
    /// ISO 8601 date on which this rate applies.
    pub on: SmolStr,
    pub span: Span,
}
