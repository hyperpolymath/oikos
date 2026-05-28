// SPDX-License-Identifier: MPL-2.0
// SPDX-FileCopyrightText: 2026 Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>

//! Parse error type for `oikos-parser`.

use thiserror::Error;

use oikos_syntax::span::Span;

/// A parse-time error.
///
/// These errors are produced by the lexer or parser before type-checking.
/// They carry source spans so that `ariadne` can produce annotated
/// source-code diagnostics.
#[derive(Debug, Error, PartialEq)]
pub enum ParseError {
    /// The lexer encountered a character sequence it could not tokenise.
    #[error("unexpected character at byte {span:?}: `{text}`")]
    UnexpectedCharacter { text: String, span: Span },

    /// The parser expected a different token.
    #[error("expected {expected}, found `{found}` at {span:?}")]
    UnexpectedToken {
        expected: String,
        found: String,
        span: Span,
    },

    /// A `godley {{ }}` block is required but absent.
    #[error("model `{model_name}` is missing a `godley {{ }}` block")]
    MissingGodleyMatrix { model_name: String, span: Span },

    /// An FX conversion referenced an undeclared rate name.
    #[error("unknown exchange rate `{rate_name}` at {span:?}")]
    UnknownFxRate { rate_name: String, span: Span },

    /// Internal error: should not reach the user.
    #[error("internal parser error: {message}")]
    Internal { message: String },
}
