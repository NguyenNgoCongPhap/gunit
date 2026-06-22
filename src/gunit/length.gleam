//// Length units — opaque newtype per display unit (Approach 1).
////
//// Distinct opaque types `Millimeter`, `Centimeter`, `Meter`. Passing one
//// where another is expected is a compile error. Names are spelled out in full
//// because Gleam types are PascalCase, which would collapse SI case (a short
//// `Mm` cannot distinguish milli- from mega-meter).
////
//// Arithmetic is provided on the canonical base unit (`Meter`): convert to the
//// base, compute, convert back. Every factor is golden-tested.

// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Cong Phap <tinhza2000@gmail.com>

// ── factors: multiply a value in <unit> by FACTOR to get meters ──

const millimeter_factor = 0.001

const centimeter_factor = 0.01

// ── opaque types ──

/// Length in millimeters.
pub opaque type Millimeter {
  Millimeter(value: Float)
}

/// Length in centimeters.
pub opaque type Centimeter {
  Centimeter(value: Float)
}

/// Length in meters. SI canonical base.
pub opaque type Meter {
  Meter(value: Float)
}

// ── constructors ──

pub fn millimeter(v: Float) -> Millimeter {
  Millimeter(v)
}

pub fn centimeter(v: Float) -> Centimeter {
  Centimeter(v)
}

pub fn meter(v: Float) -> Meter {
  Meter(v)
}

// ── extractors (raw Float in that unit) ──

pub fn millimeter_value(x: Millimeter) -> Float {
  x.value
}

pub fn centimeter_value(x: Centimeter) -> Float {
  x.value
}

pub fn meter_value(x: Meter) -> Float {
  x.value
}

// ── to base (meter) ──

pub fn millimeter_to_meter(x: Millimeter) -> Meter {
  Meter(x.value *. millimeter_factor)
}

pub fn centimeter_to_meter(x: Centimeter) -> Meter {
  Meter(x.value *. centimeter_factor)
}

// ── from base (meter) ──

pub fn meter_to_millimeter(x: Meter) -> Millimeter {
  Millimeter(x.value /. millimeter_factor)
}

pub fn meter_to_centimeter(x: Meter) -> Centimeter {
  Centimeter(x.value /. centimeter_factor)
}

// ── arithmetic on the base unit (compute here; label at the edges) ──

/// Add two lengths.
pub fn add(a: Meter, b: Meter) -> Meter {
  Meter(a.value +. b.value)
}

/// Subtract `b` from `a`.
pub fn subtract(a: Meter, b: Meter) -> Meter {
  Meter(a.value -. b.value)
}

/// Scale a length by a dimensionless factor.
pub fn scale(a: Meter, factor: Float) -> Meter {
  Meter(a.value *. factor)
}
