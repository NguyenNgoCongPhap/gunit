//// Time units — opaque newtype per display unit (Approach 1).
////
//// Distinct opaque types `Second` and `Millisecond`. Passing one where
//// another is expected is a compile error.
////
//// Arithmetic is provided on the canonical base unit (`Second`). The factor
//// is golden-tested.

// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Cong Phap <tinhza2000@gmail.com>

// ── factor: multiply a value in milliseconds by this to get seconds ──

const millisecond_factor = 0.001

// ── opaque types ──

/// Time in seconds. SI canonical base.
pub opaque type Second {
  Second(value: Float)
}

/// Time in milliseconds.
pub opaque type Millisecond {
  Millisecond(value: Float)
}

// ── constructors ──

pub fn second(v: Float) -> Second {
  Second(v)
}

pub fn millisecond(v: Float) -> Millisecond {
  Millisecond(v)
}

// ── extractors ──

pub fn second_value(x: Second) -> Float {
  x.value
}

pub fn millisecond_value(x: Millisecond) -> Float {
  x.value
}

// ── conversions ──

pub fn millisecond_to_second(x: Millisecond) -> Second {
  Second(x.value *. millisecond_factor)
}

pub fn second_to_millisecond(x: Second) -> Millisecond {
  Millisecond(x.value /. millisecond_factor)
}

// ── arithmetic on the base unit ──

/// Add two times.
pub fn add(a: Second, b: Second) -> Second {
  Second(a.value +. b.value)
}

/// Subtract `b` from `a`.
pub fn subtract(a: Second, b: Second) -> Second {
  Second(a.value -. b.value)
}

/// Scale a time by a dimensionless factor.
pub fn scale(a: Second, factor: Float) -> Second {
  Second(a.value *. factor)
}
