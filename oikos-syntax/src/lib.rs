// SPDX-License-Identifier: MPL-2.0
// SPDX-FileCopyrightText: 2026 Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>

//! `oikos-syntax` — Abstract syntax tree for the Oikos SFC modelling DSL.
//!
//! Oikos provides a typed surface language for stock-flow consistent (SFC)
//! macroeconomic modelling in the tradition of Godley & Lavoie (2007, 2012).
//! This crate defines the unelaborated parse tree produced by `oikos-parser`
//! before desugaring to Ephapax IR.
//!
//! # Naming convention
//!
//! Node names follow economic notation rather than programming-language notation:
//! economists are the primary audience.  A value that accumulates over time is a
//! **stock**; a value that changes it within a period is a **flow**.  Accounts
//! carry an explicit **dimension** (currency), and values are scoped to a
//! **fiscal period**.  Financial contracts progress through well-defined
//! **states** (draft → issued → settled).
//!
//! # Crate layout
//!
//! | Module | Contents |
//! |--------|----------|
//! | [`span`]       | Source-location types (`Span`, `Spanned<T>`) |
//! | [`dimension`]  | Monetary dimension nodes (`CurrencyCode`, `FxRate`) |
//! | [`account`]    | Stock and flow account declarations |
//! | [`period`]     | Fiscal period (region) declarations |
//! | [`sector`]     | Sector declarations and balance-sheet structure |
//! | [`godley`]     | Godley matrix node — the global accounting identity |
//! | [`instrument`] | Financial instrument declarations with typestate |
//! | [`expr`]       | Expressions: transfers, FX conversions, closures |
//! | [`model`]      | Top-level `model` declaration |
//! | [`error`]      | Syntax-level error type |

pub mod account;
pub mod dimension;
pub mod error;
pub mod expr;
pub mod godley;
pub mod instrument;
pub mod model;
pub mod period;
pub mod sector;
pub mod span;

// ── Convenience re-exports ────────────────────────────────────────────────────

pub use account::{AccountDecl, AccountKind};
pub use dimension::{CurrencyCode, FxRate, MoneyLiteral};
pub use error::SyntaxError;
pub use expr::{Expr, TransferExpr};
pub use godley::{GodleyCell, GodleyMatrix, GodleySign};
pub use instrument::{InstrumentDecl, InstrumentState};
pub use model::Model;
pub use period::PeriodDecl;
pub use sector::SectorDecl;
pub use span::{Span, Spanned};
