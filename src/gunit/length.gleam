//// Length units — opaque newtype per display unit (Approach 1).
////
//// Distinct opaque types `Millimeter`, `Centimeter`, `Meter`, plus the
//// US-customary `Inch` and `Foot`. Passing one where another is expected is
//// a compile error. Names are spelled out in full because Gleam types are
//// PascalCase, which would collapse SI case (a short `Mm` cannot distinguish
//// milli- from mega-meter).
////
//// Arithmetic is provided on the canonical base unit (`Meter`): convert to the
//// base, compute, convert back. Every factor is golden-tested.

// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Cong Phap <tinhza2000@gmail.com>

// ── factors: multiply a value in <unit> by FACTOR to get meters ──
// inch and foot are exact by the international yard-and-pound agreement of
// 1959: 1 in = 0.0254 m; 1 ft = 12 in = 0.3048 m. Source: NIST SP 811.

const millimeter_factor = 0.001

const centimeter_factor = 0.01

const inch_factor = 0.0254

const foot_factor = 0.3048

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

/// Length in inches (US customary). 1 in = 0.0254 m.
pub opaque type Inch {
  Inch(value: Float)
}

/// Length in feet (US customary). 1 ft = 0.3048 m.
pub opaque type Foot {
  Foot(value: Float)
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

pub fn inch(v: Float) -> Inch {
  Inch(v)
}

pub fn foot(v: Float) -> Foot {
  Foot(v)
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

pub fn inch_value(x: Inch) -> Float {
  x.value
}

pub fn foot_value(x: Foot) -> Float {
  x.value
}

// ── to base (meter) ──

pub fn millimeter_to_meter(x: Millimeter) -> Meter {
  Meter(x.value *. millimeter_factor)
}

pub fn centimeter_to_meter(x: Centimeter) -> Meter {
  Meter(x.value *. centimeter_factor)
}

pub fn inch_to_meter(x: Inch) -> Meter {
  Meter(x.value *. inch_factor)
}

pub fn foot_to_meter(x: Foot) -> Meter {
  Meter(x.value *. foot_factor)
}

// ── from base (meter) ──

pub fn meter_to_millimeter(x: Meter) -> Millimeter {
  Millimeter(x.value /. millimeter_factor)
}

pub fn meter_to_centimeter(x: Meter) -> Centimeter {
  Centimeter(x.value /. centimeter_factor)
}

pub fn meter_to_inch(x: Meter) -> Inch {
  Inch(x.value /. inch_factor)
}

pub fn meter_to_foot(x: Meter) -> Foot {
  Foot(x.value /. foot_factor)
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
