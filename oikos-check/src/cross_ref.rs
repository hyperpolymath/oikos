// SPDX-License-Identifier: MPL-2.0
// SPDX-FileCopyrightText: 2026 Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>

//! Cross-reference checker.
//!
//! Verifies that every name used in the model body (transfers, close
//! expressions, Godley matrix, sector balance sheets) refers to something
//! that was declared in the same model.
//!
//! Also checks:
//! * `active_period` names a declared period.
//! * `close from P into Q`: both P and Q are declared periods.
//! * `convert … via R`: R is a declared FX rate.
//! * Godley matrix sector headers match declared sectors.
//! * Sector `asset`/`liability` entries reference declared accounts.

use oikos_syntax::{
    expr::{Expr, MoneyExpr},
    span::Span,
    Model,
};

use crate::{error::CheckError, resolve::SymbolTable};

/// Run cross-reference checks, returning all errors found.
pub fn check(model: &Model, symbols: &SymbolTable<'_>) -> Vec<CheckError> {
    let mut errors: Vec<CheckError> = Vec::new();

    // active_period must name a declared period (or be a bare name if no
    // periods are declared — tolerated as a forward reference for now).
    if !model.periods.is_empty() && symbols.period(model.active_period.as_str()).is_none() {
        errors.push(CheckError::UnknownActivePeriod {
            name: model.active_period.to_string(),
            span: model.span,
        });
    }

    // Godley matrix: sector headers must match declared sectors (when sectors exist).
    if !model.sectors.is_empty() {
        for sector_name in &model.godley.sectors {
            if symbols.sector(sector_name.as_str()).is_none() {
                errors.push(CheckError::UnknownSector {
                    name: sector_name.to_string(),
                    span: Span::SYNTHETIC,
                });
            }
        }
    }

    // Godley matrix: account rows must reference declared accounts
    // (only when the model has account declarations — a model with no
    // declarations is still being scaffolded and we avoid spurious errors).
    if !model.accounts.is_empty() {
        for aref in &model.godley.accounts {
            if symbols.account(aref.name.as_str()).is_none() {
                errors.push(CheckError::UnknownAccount {
                    name: aref.name.to_string(),
                    span: aref.span,
                });
            }
        }
    }

    // Sector balance sheets: assets and liabilities must reference declared accounts.
    for sector in &model.sectors {
        for aref in sector.assets.iter().chain(sector.liabilities.iter()) {
            if symbols.account(aref.name.as_str()).is_none() {
                errors.push(CheckError::UnknownAccount {
                    name: aref.name.to_string(),
                    span: aref.span,
                });
            }
        }
    }

    // Model body: transfers and close expressions.
    for expr in &model.body {
        match expr {
            Expr::Transfer(t) => {
                if symbols.account(t.from.name.as_str()).is_none() {
                    errors.push(CheckError::UnknownAccount {
                        name: t.from.name.to_string(),
                        span: t.from.span,
                    });
                }
                if symbols.account(t.to.name.as_str()).is_none() {
                    errors.push(CheckError::UnknownAccount {
                        name: t.to.name.to_string(),
                        span: t.to.span,
                    });
                }
                // balance(account) and fraction(_, account) refs in amount
                check_money_expr(&t.amount, symbols, &mut errors);
            }

            Expr::PeriodClose(c) => {
                if symbols.account(c.account.name.as_str()).is_none() {
                    errors.push(CheckError::UnknownAccount {
                        name: c.account.name.to_string(),
                        span: c.account.span,
                    });
                }
                if symbols.period(c.from_period.as_str()).is_none() {
                    errors.push(CheckError::UnknownPeriod {
                        name: c.from_period.to_string(),
                        span: c.span,
                    });
                }
                if symbols.period(c.to_period.as_str()).is_none() {
                    errors.push(CheckError::UnknownPeriod {
                        name: c.to_period.to_string(),
                        span: c.span,
                    });
                }
            }

            Expr::FxConversion(fx) => {
                check_money_expr(&fx.amount, symbols, &mut errors);
                if symbols.fx_rate(fx.rate_name.as_str()).is_none() {
                    errors.push(CheckError::UnknownFxRate {
                        name: fx.rate_name.to_string(),
                        span: fx.span,
                    });
                }
                if symbols.account(fx.destination.name.as_str()).is_none() {
                    errors.push(CheckError::UnknownAccount {
                        name: fx.destination.name.to_string(),
                        span: fx.destination.span,
                    });
                }
            }
        }
    }

    errors
}

fn check_money_expr(expr: &MoneyExpr, symbols: &SymbolTable<'_>, errors: &mut Vec<CheckError>) {
    match expr {
        MoneyExpr::Literal(_) => {}
        MoneyExpr::Balance(aref) => {
            if symbols.account(aref.name.as_str()).is_none() {
                errors.push(CheckError::UnknownAccount {
                    name: aref.name.to_string(),
                    span: aref.span,
                });
            }
        }
        MoneyExpr::Fraction { account, .. } => {
            if symbols.account(account.name.as_str()).is_none() {
                errors.push(CheckError::UnknownAccount {
                    name: account.name.to_string(),
                    span: account.span,
                });
            }
        }
    }
}
