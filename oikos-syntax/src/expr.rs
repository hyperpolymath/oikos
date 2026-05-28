// SPDX-License-Identifier: MPL-2.0
// SPDX-FileCopyrightText: 2026 Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>

//! Expressions: transfers, FX conversions, and period closures.
//!
//! The central expression in Oikos is the **transfer**: a linear move of
//! monetary value from one account to another.  Linearity is enforced by the
//! Ephapax type system: after a transfer the source account's value is
//! consumed at the type level, making double-counting structurally impossible.
//!
//! FX conversions are explicit: you cannot transfer GBP from a GBP account
//! into a USD account without naming a dated exchange rate.
//!
//! Period closures carry a stock value across a period boundary.

use serde::{Deserialize, Serialize};
use smol_str::SmolStr;

use crate::dimension::MoneyLiteral;
use crate::sector::AccountRef;
use crate::span::Span;

/// A monetary expression: either a literal amount or a reference to an
/// account's current balance.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum MoneyExpr {
    /// A literal monetary amount: `2_500.00 GBP`.
    Literal(MoneyLiteral),
    /// The full balance of an account: `balance(deposits)`.
    Balance(AccountRef),
    /// A fraction of an account's balance: `fraction(0.20, deposits)`.
    Fraction {
        /// Fraction in `[0, 1]`, stored as a string for precision.
        ratio: SmolStr,
        account: AccountRef,
        span: Span,
    },
}

/// A linear monetary transfer between two accounts.
///
/// Desugars to a linear `consume`/`produce` pair in Ephapax.  The source
/// account is consumed and the destination account is produced; the compiler
/// rejects any code path that would allow the source value to be used again
/// after the transfer.
///
/// Surface syntax:
///
/// ```text
/// transfer wages → deposits {
///     amount:      2_500.00 GBP
///     description: "Monthly salary payment"
/// }
/// ```
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct TransferExpr {
    /// The account from which funds are drawn (consumed).
    pub from: AccountRef,
    /// The account into which funds are credited (produced).
    pub to: AccountRef,
    /// The amount to transfer.
    pub amount: MoneyExpr,
    /// Optional prose description for audit trails.
    pub description: Option<SmolStr>,
    pub span: Span,
}

/// An FX conversion: converts an amount from one currency to another using
/// a named, dated exchange rate.
///
/// Surface syntax:
///
/// ```text
/// convert 1_000.00 GBP via GBP_USD_2025Q4 into usd_account
/// ```
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct FxConversionExpr {
    pub amount: MoneyExpr,
    /// Name of the `FxRate` declared in this model.
    pub rate_name: SmolStr,
    pub destination: AccountRef,
    pub span: Span,
}

/// Carry a stock value across a period boundary.
///
/// A value scoped to period `P` cannot appear in expressions for period `P+1`
/// without an explicit close that records the end-of-period balance and
/// transfers ownership to the new period's scope.
///
/// Surface syntax:
///
/// ```text
/// close deposits from FY2024 into FY2025
/// ```
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct PeriodCloseExpr {
    pub account: AccountRef,
    pub from_period: SmolStr,
    pub to_period: SmolStr,
    pub span: Span,
}

/// Any expression valid at statement level within a model body.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum Expr {
    Transfer(TransferExpr),
    FxConversion(FxConversionExpr),
    PeriodClose(PeriodCloseExpr),
}
