//// Frequency — opaque newtype per display unit.
////
//// A single display unit today (`Hz`), used for modal-analysis natural
//// frequencies. The reciprocal quantity (period, in seconds) lives in
//// `gunit/time` and is deliberately NOT auto-converted here: 1/f is a
//// different physical quantity, and silently crossing the two is the very
//// mistake this library exists to catch.

// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Cong Phap <tinhza2000@gmail.com>

// ── opaque types ──

/// Frequency in hertz (cycles per second).
pub opaque type Hz {
  Hz(value: Float)
}

// ── constructors ──

pub fn hz(v: Float) -> Hz {
  Hz(v)
}

// ── extractors ──

pub fn hz_value(x: Hz) -> Float {
  x.value
}

// ── arithmetic ──

/// Add two frequencies.
pub fn add(a: Hz, b: Hz) -> Hz {
  Hz(a.value +. b.value)
}

/// Subtract `b` from `a`.
pub fn subtract(a: Hz, b: Hz) -> Hz {
  Hz(a.value -. b.value)
}

/// Scale a frequency by a dimensionless factor.
pub fn scale(a: Hz, factor: Float) -> Hz {
  Hz(a.value *. factor)
}
