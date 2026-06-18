// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
// SPDX-FileCopyrightText: 2026 Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>

//! `oikos-parser` — Logos lexer and Chumsky parser for the Oikos DSL.
//!
//! # Pipeline
//!
//! ```text
//! source text
//!   └─▶ Lexer (Logos)    → Vec<(Token, SimpleSpan)>
//!         └─▶ Parser (Chumsky) → oikos_syntax::Model
//! ```
//!
//! # Implemented constructs
//!
//! `period`, `account`, `sector`, `godley`, `transfer`, `close`, `model`.
//! Stubs remain for `instrument`, `rate`, and `convert`.

pub mod error;
pub mod lexer;
pub mod parser;

pub use error::ParseError;
pub use oikos_syntax::Model;

/// Parse an Oikos source string into an AST.
///
/// Returns `(Some(model), warnings)` on success (warnings may be empty),
/// or `(None, errors)` / `(Some(partial), errors)` on failure.
/// Errors are non-fatal where Chumsky can recover a partial tree.
///
/// # Arguments
///
/// * `source`   — full text of a `.oikos` file
/// * `filename` — used only in future diagnostic messages
pub fn parse(
    source: &str,
    _filename: &str,
) -> Result<(Option<Model>, Vec<ParseError>), ParseError> {
    parser::parse_model(source)
}
