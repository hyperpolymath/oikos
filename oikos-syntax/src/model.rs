// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
// SPDX-FileCopyrightText: 2026 Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>

//! Top-level `model` declaration — the root of an Oikos source file.

use serde::{Deserialize, Serialize};
use smol_str::SmolStr;

use crate::account::AccountDecl;
use crate::dimension::FxRate;
use crate::expr::Expr;
use crate::godley::GodleyMatrix;
use crate::instrument::InstrumentDecl;
use crate::period::PeriodDecl;
use crate::sector::SectorDecl;
use crate::span::Span;

/// The root node of an Oikos source file.
///
/// A model declares periods, sectors, accounts, instruments, exchange rates,
/// a Godley matrix, and a sequence of transfer/close expressions.
///
/// Surface syntax:
///
/// ```text
/// model UKBaselineModel (period: FY2025) {
///
///     period FY2025 : FiscalYear from 2025-04-01 to 2026-03-31
///
///     rate GBP_USD_Q4 : FxRate(GBP → USD) = 1.2650 on 2025-12-31
///
///     account deposits      : Stock GBP
///     account wages         : Flow  GBP
///     account taxes         : Flow  GBP
///     account govt_spending : Flow  GBP
///
///     instrument Invoice : GBP { ... }
///
///     sector Households { asset deposits; liability mortgage }
///     sector Government { asset tax_receivable; liability bonds }
///
///     godley {
///         | Account   | Households | Government |
///         | deposits  | +          | -          |
///         | taxes     | -          | +          |
///     }
///
///     transfer wages → deposits { amount: 45_000.00 GBP }
///     transfer deposits → taxes { amount: 9_000.00 GBP }
/// }
/// ```
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Model {
    /// Model identifier.
    pub name: SmolStr,
    /// The fiscal period in which this model's expressions execute.
    pub active_period: SmolStr,
    /// All period declarations.
    pub periods: Vec<PeriodDecl>,
    /// All FX rate declarations.
    pub fx_rates: Vec<FxRate>,
    /// Model-level account declarations (shared across sectors).
    pub accounts: Vec<AccountDecl>,
    /// Financial instrument type declarations.
    pub instruments: Vec<InstrumentDecl>,
    /// Sector declarations.
    pub sectors: Vec<SectorDecl>,
    /// The Godley transactions matrix.  Must be present; its absence is a
    /// parse error (the accounting identity is mandatory, not optional).
    pub godley: GodleyMatrix,
    /// The ordered sequence of transfer and close expressions.
    pub body: Vec<Expr>,
    pub span: Span,
}
