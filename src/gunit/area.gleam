//// Area units — opaque newtype per display unit (Approach 1), mirroring
//// `gunit/length`.
////
//// Distinct opaque types `SquareMillimeter`, `SquareCentimeter`,
//// `SquareMeter`. Passing one where another is expected is a compile error.
//// The canonical base is `SquareMeter`; arithmetic converts to the base,
//// computes, and converts back. Every factor is golden-tested.
////
//// Factors are the square of the matching `gunit/length` factor: 1 mm2 =
//// (0.001 m)^2 = 1e-6 m2; 1 cm2 = (0.01 m)^2 = 1e-4 m2.

// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Cong Phap <tinhza2000@gmail.com>

// ── factors: multiply a value in <unit> by FACTOR to get square meters ──

const square_millimeter_factor = 0.000001

const square_centimeter_factor = 0.0001

// ── opaque types ──

/// Area in square millimeters.
pub opaque type SquareMillimeter {
  SquareMillimeter(value: Float)
}

/// Area in square centimeters.
pub opaque type SquareCentimeter {
  SquareCentimeter(value: Float)
}

/// Area in square meters. SI canonical base.
pub opaque type SquareMeter {
  SquareMeter(value: Float)
}

// ── constructors ──

pub fn square_millimeter(v: Float) -> SquareMillimeter {
  SquareMillimeter(v)
}

pub fn square_centimeter(v: Float) -> SquareCentimeter {
  SquareCentimeter(v)
}

pub fn square_meter(v: Float) -> SquareMeter {
  SquareMeter(v)
}

// ── extractors (raw Float in that unit) ──

pub fn square_millimeter_value(x: SquareMillimeter) -> Float {
  x.value
}

pub fn square_centimeter_value(x: SquareCentimeter) -> Float {
  x.value
}

pub fn square_meter_value(x: SquareMeter) -> Float {
  x.value
}

// ── to base (square meter) ──

pub fn square_millimeter_to_square_meter(x: SquareMillimeter) -> SquareMeter {
  SquareMeter(x.value *. square_millimeter_factor)
}

pub fn square_centimeter_to_square_meter(x: SquareCentimeter) -> SquareMeter {
  SquareMeter(x.value *. square_centimeter_factor)
}

// ── from base (square meter) ──

pub fn square_meter_to_square_millimeter(x: SquareMeter) -> SquareMillimeter {
  SquareMillimeter(x.value /. square_millimeter_factor)
}

pub fn square_meter_to_square_centimeter(x: SquareMeter) -> SquareCentimeter {
  SquareCentimeter(x.value /. square_centimeter_factor)
}

// ── arithmetic on the base unit (compute here; label at the edges) ──

/// Add two areas.
pub fn add(a: SquareMeter, b: SquareMeter) -> SquareMeter {
  SquareMeter(a.value +. b.value)
}

/// Subtract `b` from `a`.
pub fn subtract(a: SquareMeter, b: SquareMeter) -> SquareMeter {
  SquareMeter(a.value -. b.value)
}

/// Scale an area by a dimensionless factor.
pub fn scale(a: SquareMeter, factor: Float) -> SquareMeter {
  SquareMeter(a.value *. factor)
}
