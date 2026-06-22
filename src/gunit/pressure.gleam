//// Pressure / stress units — opaque newtype per display unit (Approach 1).
////
//// Distinct opaque types `Pascal`, `Kilopascal`, `Megapascal`, `Gigapascal`,
//// `KgfPerCm2`. Names are spelled out because PascalCase would collapse SI case
//// (a short `Mpa` cannot tell mega- from milli-pascal). The silent danger this
//// guards against is prefix confusion: kPa vs MPa is a 1000x error.
////
//// Arithmetic is provided on the canonical base unit (`Pascal`). Every factor
//// is golden-tested.

// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Cong Phap <tinhza2000@gmail.com>

// ── factors: multiply a value in <unit> by FACTOR to get pascals ──
// kgf/cm2 derives from g0: 1 kgf/cm2 = 9.80665 N / (0.01 m)^2 = 98066.5 Pa.

const kilopascal_factor = 1000.0

const megapascal_factor = 1_000_000.0

const gigapascal_factor = 1_000_000_000.0

const kgf_per_cm2_factor = 98_066.5

// ── opaque types ──

/// Pressure / stress in pascals. SI canonical base.
pub opaque type Pascal {
  Pascal(value: Float)
}

/// Pressure / stress in kilopascals (kN/m2).
pub opaque type Kilopascal {
  Kilopascal(value: Float)
}

/// Pressure / stress in megapascals (N/mm2).
pub opaque type Megapascal {
  Megapascal(value: Float)
}

/// Pressure / stress in gigapascals.
pub opaque type Gigapascal {
  Gigapascal(value: Float)
}

/// Pressure / stress in kgf/cm2. 1 kgf/cm2 = 98066.5 Pa.
pub opaque type KgfPerCm2 {
  KgfPerCm2(value: Float)
}

// ── constructors ──

pub fn pascal(v: Float) -> Pascal {
  Pascal(v)
}

pub fn kilopascal(v: Float) -> Kilopascal {
  Kilopascal(v)
}

pub fn megapascal(v: Float) -> Megapascal {
  Megapascal(v)
}

pub fn gigapascal(v: Float) -> Gigapascal {
  Gigapascal(v)
}

pub fn kgf_per_cm2(v: Float) -> KgfPerCm2 {
  KgfPerCm2(v)
}

// ── extractors ──

pub fn pascal_value(x: Pascal) -> Float {
  x.value
}

pub fn kilopascal_value(x: Kilopascal) -> Float {
  x.value
}

pub fn megapascal_value(x: Megapascal) -> Float {
  x.value
}

pub fn gigapascal_value(x: Gigapascal) -> Float {
  x.value
}

pub fn kgf_per_cm2_value(x: KgfPerCm2) -> Float {
  x.value
}

// ── to base (pascal) ──

pub fn kilopascal_to_pascal(x: Kilopascal) -> Pascal {
  Pascal(x.value *. kilopascal_factor)
}

pub fn megapascal_to_pascal(x: Megapascal) -> Pascal {
  Pascal(x.value *. megapascal_factor)
}

pub fn gigapascal_to_pascal(x: Gigapascal) -> Pascal {
  Pascal(x.value *. gigapascal_factor)
}

pub fn kgf_per_cm2_to_pascal(x: KgfPerCm2) -> Pascal {
  Pascal(x.value *. kgf_per_cm2_factor)
}

// ── from base (pascal) ──

pub fn pascal_to_kilopascal(x: Pascal) -> Kilopascal {
  Kilopascal(x.value /. kilopascal_factor)
}

pub fn pascal_to_megapascal(x: Pascal) -> Megapascal {
  Megapascal(x.value /. megapascal_factor)
}

pub fn pascal_to_gigapascal(x: Pascal) -> Gigapascal {
  Gigapascal(x.value /. gigapascal_factor)
}

pub fn pascal_to_kgf_per_cm2(x: Pascal) -> KgfPerCm2 {
  KgfPerCm2(x.value /. kgf_per_cm2_factor)
}

// ── arithmetic on the base unit ──

/// Add two pressures.
pub fn add(a: Pascal, b: Pascal) -> Pascal {
  Pascal(a.value +. b.value)
}

/// Subtract `b` from `a`.
pub fn subtract(a: Pascal, b: Pascal) -> Pascal {
  Pascal(a.value -. b.value)
}

/// Scale a pressure by a dimensionless factor.
pub fn scale(a: Pascal, factor: Float) -> Pascal {
  Pascal(a.value *. factor)
}
