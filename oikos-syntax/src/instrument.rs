// SPDX-License-Identifier: MPL-2.0
// SPDX-FileCopyrightText: 2026 Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>

//! Financial instrument declarations with typestate.
//!
//! A financial instrument (invoice, bond, loan, etc.) progresses through a
//! well-defined sequence of states during its lifecycle.  Oikos encodes this
//! as a typestate machine that desugars to Ephapax typestate.
//!
//! Invalid state transitions are rejected at compile time: a `Void` invoice
//! cannot be settled; a `Settled` bond cannot become `Issued` again.
//!
//! Default lifecycle for an `Invoice`:
//!
//! ```text
//! Draft → Issued → PartiallyPaid → Settled
//!                                ↘ Void
//!       ↘ Void
//! ```

use serde::{Deserialize, Serialize};
use smol_str::SmolStr;

use crate::dimension::CurrencyCode;
use crate::span::Span;

/// A state in an instrument's lifecycle typestate machine.
///
/// The built-in states cover the common invoice/bond lifecycle.  A model may
/// declare additional states for domain-specific instruments.
#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum InstrumentState {
    /// Created but not yet formally issued.
    Draft,
    /// Formally issued; liability recognised on issuer's balance sheet.
    Issued,
    /// One or more partial payments received; not yet fully settled.
    PartiallyPaid,
    /// All obligations discharged; instrument closed.
    Settled,
    /// Cancelled before settlement; no further transitions permitted.
    Void,
    /// A domain-specific state declared by the model.
    Custom(SmolStr),
}

/// A state transition permitted by the instrument's typestate machine.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct StateTransition {
    pub from: InstrumentState,
    pub to: InstrumentState,
    pub span: Span,
}

/// Declaration of a financial instrument type.
///
/// Surface syntax:
///
/// ```text
/// instrument Invoice : GBP {
///     states  Draft, Issued, PartiallyPaid, Settled, Void
///     initial Draft
///     transitions {
///         Draft          → Issued
///         Draft          → Void
///         Issued         → PartiallyPaid
///         Issued         → Void
///         PartiallyPaid  → Settled
///         PartiallyPaid  → Void
///     }
/// }
/// ```
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct InstrumentDecl {
    /// Instrument type name (e.g. `Invoice`, `TreasuryBill`).
    pub name: SmolStr,
    /// The currency in which this instrument is denominated.
    pub currency: CurrencyCode,
    /// All states in this instrument's typestate machine.
    pub states: Vec<InstrumentState>,
    /// The initial state of a newly created instrument.
    pub initial: InstrumentState,
    /// The permitted state transitions.
    pub transitions: Vec<StateTransition>,
    /// Optional prose description.
    pub description: Option<SmolStr>,
    pub span: Span,
}
