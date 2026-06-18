// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
// SPDX-FileCopyrightText: 2026 Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>

//! `oikos-desugar` — desugaring pass from Oikos AST to Ephapax IR.
//!
//! # Status: blocked
//!
//! This crate is **blocked on the Ephapax parser** (`hyperpolymath/ephapax`).
//! Ephapax `ephapax-ir` and `ephapax-typing` crates exist and are stable, but
//! end-to-end use of Oikos requires the Ephapax surface-language parser (which
//! is not yet complete).  The desugaring logic is designed here; the Ephapax
//! IR dependency is commented out in `Cargo.toml` until that milestone ships.
//!
//! # Desugaring map
//!
//! | Oikos construct          | Ephapax IR target                                  |
//! |--------------------------|-----------------------------------------------------|
//! | `Stock GBP`              | Linear value with phantom type `Gbp`                |
//! | `Flow GBP`               | Linear value with phantom type `Flow<Gbp>`          |
//! | Fiscal period            | Tofte–Talpin region                                 |
//! | `transfer A → B`         | `let v = consume(A); produce(B, v)`                 |
//! | `convert … via rate`     | `let v = consume(A); produce(B, fx(v, rate))`       |
//! | `close A from P into Q`  | Region-end finaliser + new-region initialiser        |
//! | Instrument typestate     | Ephapax typestate machine                           |
//! | Godley matrix invariant  | Module-level linear type constraint                 |

pub mod error;

pub use error::DesugarError;
use oikos_syntax::Model;

/// Placeholder for the Ephapax IR module root.
///
/// Replace with `use ephapax_ir::Module;` once the dependency is available.
pub struct EphapaxIr; // placeholder

/// Desugar an Oikos [`Model`] into an Ephapax IR module.
///
/// # Errors
///
/// Returns [`DesugarError::EphapaxNotAvailable`] until the Ephapax IR
/// dependency is wired in.  Other error variants cover semantic problems
/// detected during desugaring (e.g. Godley column imbalance).
pub fn desugar(_model: &Model) -> Result<EphapaxIr, DesugarError> {
    Err(DesugarError::EphapaxNotAvailable)
}
