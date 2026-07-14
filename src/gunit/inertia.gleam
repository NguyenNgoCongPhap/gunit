//// Second moment of area — opaque newtype per display unit.
////
//// A single display unit today (`Mm4`), because steel-section catalogs and the
//// structural wire formats that feed this library all report second moment of
//// area in mm4. Additional display units (cm4 for EN catalogs, in4 for AISC)
//// are an additive change the day a consumer needs them.

// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Cong Phap <tinhza2000@gmail.com>

// ── opaque types ──

/// Second moment of area in mm4. Used for `Ixx` / `Iyy` / `Izz`.
pub opaque type Mm4 {
  Mm4(value: Float)
}

// ── constructors ──

pub fn mm4(v: Float) -> Mm4 {
  Mm4(v)
}

// ── extractors ──

pub fn mm4_value(x: Mm4) -> Float {
  x.value
}

// ── arithmetic ──

/// Add two second moments of area.
pub fn add(a: Mm4, b: Mm4) -> Mm4 {
  Mm4(a.value +. b.value)
}

/// Subtract `b` from `a`.
pub fn subtract(a: Mm4, b: Mm4) -> Mm4 {
  Mm4(a.value -. b.value)
}

/// Scale a second moment of area by a dimensionless factor.
pub fn scale(a: Mm4, factor: Float) -> Mm4 {
  Mm4(a.value *. factor)
}
