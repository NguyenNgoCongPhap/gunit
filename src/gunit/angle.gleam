//// Angle units — opaque newtype per display unit (Approach 1).
////
//// Distinct opaque types `Radian` and `Degree`. Trig functions expect radians;
//// feeding degrees in silently is a classic bug, so the conversion is explicit.
////
//// Arithmetic is provided on the canonical base unit (`Radian`). The factor is
//// golden-tested.

// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Cong Phap <tinhza2000@gmail.com>

// ── factor: multiply a value in degrees by this to get radians (pi / 180) ──

const degree_factor = 0.017453292519943295

// ── opaque types ──

/// Angle in radians. SI canonical base (trig-native).
pub opaque type Radian {
  Radian(value: Float)
}

/// Angle in degrees.
pub opaque type Degree {
  Degree(value: Float)
}

// ── constructors ──

pub fn radian(v: Float) -> Radian {
  Radian(v)
}

pub fn degree(v: Float) -> Degree {
  Degree(v)
}

// ── extractors ──

pub fn radian_value(x: Radian) -> Float {
  x.value
}

pub fn degree_value(x: Degree) -> Float {
  x.value
}

// ── conversions ──

pub fn degree_to_radian(x: Degree) -> Radian {
  Radian(x.value *. degree_factor)
}

pub fn radian_to_degree(x: Radian) -> Degree {
  Degree(x.value /. degree_factor)
}

// ── arithmetic on the base unit ──

/// Add two angles.
pub fn add(a: Radian, b: Radian) -> Radian {
  Radian(a.value +. b.value)
}

/// Subtract `b` from `a`.
pub fn subtract(a: Radian, b: Radian) -> Radian {
  Radian(a.value -. b.value)
}

/// Scale an angle by a dimensionless factor.
pub fn scale(a: Radian, factor: Float) -> Radian {
  Radian(a.value *. factor)
}
