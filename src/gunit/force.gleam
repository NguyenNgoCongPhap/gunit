//// Force units — opaque newtype per display unit (Approach 1).
////
//// Distinct opaque types `Newton`, `Kilonewton`, `Meganewton`,
//// `KilogramForce`, `TonneForce` (coherent SI N / kN / MN plus the
//// gravitational-metric kgf and tonne-force). Names are spelled out because
//// PascalCase would collapse SI case (a short `Mn` cannot tell mega- from
//// milli-newton).
////
//// Arithmetic is provided on the canonical base unit (`Newton`). Every factor
//// is golden-tested.

// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Cong Phap <tinhza2000@gmail.com>

// ── factors: multiply a value in <unit> by FACTOR to get newtons ──
// kgf is exact by definition: 1 kgf = standard gravity g0 = 9.80665 N.
// tonne-force = 1000 kgf (the tonne, symbol t). Source: NIST SP 811 / ISO 80000-4.

const kilonewton_factor = 1000.0

const meganewton_factor = 1_000_000.0

const kilogram_force_factor = 9.80665

const tonne_force_factor = 9806.65

// ── opaque types ──

/// Force in newtons. SI canonical base.
pub opaque type Newton {
  Newton(value: Float)
}

/// Force in kilonewtons.
pub opaque type Kilonewton {
  Kilonewton(value: Float)
}

/// Force in meganewtons.
pub opaque type Meganewton {
  Meganewton(value: Float)
}

/// Force in kilogram-force. 1 kgf = 9.80665 N.
pub opaque type KilogramForce {
  KilogramForce(value: Float)
}

/// Force in tonne-force (1 tonne = 1000 kg). 1 tonne-force = 9806.65 N.
pub opaque type TonneForce {
  TonneForce(value: Float)
}

// ── constructors ──

pub fn newton(v: Float) -> Newton {
  Newton(v)
}

pub fn kilonewton(v: Float) -> Kilonewton {
  Kilonewton(v)
}

pub fn meganewton(v: Float) -> Meganewton {
  Meganewton(v)
}

pub fn kilogram_force(v: Float) -> KilogramForce {
  KilogramForce(v)
}

pub fn tonne_force(v: Float) -> TonneForce {
  TonneForce(v)
}

// ── extractors ──

pub fn newton_value(x: Newton) -> Float {
  x.value
}

pub fn kilonewton_value(x: Kilonewton) -> Float {
  x.value
}

pub fn meganewton_value(x: Meganewton) -> Float {
  x.value
}

pub fn kilogram_force_value(x: KilogramForce) -> Float {
  x.value
}

pub fn tonne_force_value(x: TonneForce) -> Float {
  x.value
}

// ── to base (newton) ──

pub fn kilonewton_to_newton(x: Kilonewton) -> Newton {
  Newton(x.value *. kilonewton_factor)
}

pub fn meganewton_to_newton(x: Meganewton) -> Newton {
  Newton(x.value *. meganewton_factor)
}

pub fn kilogram_force_to_newton(x: KilogramForce) -> Newton {
  Newton(x.value *. kilogram_force_factor)
}

pub fn tonne_force_to_newton(x: TonneForce) -> Newton {
  Newton(x.value *. tonne_force_factor)
}

// ── from base (newton) ──

pub fn newton_to_kilonewton(x: Newton) -> Kilonewton {
  Kilonewton(x.value /. kilonewton_factor)
}

pub fn newton_to_meganewton(x: Newton) -> Meganewton {
  Meganewton(x.value /. meganewton_factor)
}

pub fn newton_to_kilogram_force(x: Newton) -> KilogramForce {
  KilogramForce(x.value /. kilogram_force_factor)
}

pub fn newton_to_tonne_force(x: Newton) -> TonneForce {
  TonneForce(x.value /. tonne_force_factor)
}

// ── arithmetic on the base unit ──

/// Add two forces.
pub fn add(a: Newton, b: Newton) -> Newton {
  Newton(a.value +. b.value)
}

/// Subtract `b` from `a`.
pub fn subtract(a: Newton, b: Newton) -> Newton {
  Newton(a.value -. b.value)
}

/// Scale a force by a dimensionless factor.
pub fn scale(a: Newton, factor: Float) -> Newton {
  Newton(a.value *. factor)
}
