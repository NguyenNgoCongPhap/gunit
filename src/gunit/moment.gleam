//// Bending-moment units — opaque newtype per display unit (Approach 1).
////
//// Distinct opaque types `NewtonMeter`, `KilonewtonMeter`,
//// `KilogramForceMeter`, `TonneForceMeter`. Moment is force x length, so a unit
//// slip compounds two factors at once; distinct types prevent it.
////
//// Arithmetic is provided on the canonical base unit (`NewtonMeter`). Every
//// factor is golden-tested.

// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Cong Phap <tinhza2000@gmail.com>

// ── factors: multiply a value in <unit> by FACTOR to get newton-meters ──
// kgf.m = 9.80665 N.m (g0); tonne-force.m = 1000 kgf.m = 9806.65 N.m.

const kilonewton_meter_factor = 1000.0

const kilogram_force_meter_factor = 9.80665

const tonne_force_meter_factor = 9806.65

// ── opaque types ──

/// Bending moment in newton-meters. SI canonical base.
pub opaque type NewtonMeter {
  NewtonMeter(value: Float)
}

/// Bending moment in kilonewton-meters.
pub opaque type KilonewtonMeter {
  KilonewtonMeter(value: Float)
}

/// Bending moment in kilogram-force-meters. 1 kgf.m = 9.80665 N.m.
pub opaque type KilogramForceMeter {
  KilogramForceMeter(value: Float)
}

/// Bending moment in tonne-force-meters. 1 tonne-force.m = 9806.65 N.m.
pub opaque type TonneForceMeter {
  TonneForceMeter(value: Float)
}

// ── constructors ──

pub fn newton_meter(v: Float) -> NewtonMeter {
  NewtonMeter(v)
}

pub fn kilonewton_meter(v: Float) -> KilonewtonMeter {
  KilonewtonMeter(v)
}

pub fn kilogram_force_meter(v: Float) -> KilogramForceMeter {
  KilogramForceMeter(v)
}

pub fn tonne_force_meter(v: Float) -> TonneForceMeter {
  TonneForceMeter(v)
}

// ── extractors ──

pub fn newton_meter_value(x: NewtonMeter) -> Float {
  x.value
}

pub fn kilonewton_meter_value(x: KilonewtonMeter) -> Float {
  x.value
}

pub fn kilogram_force_meter_value(x: KilogramForceMeter) -> Float {
  x.value
}

pub fn tonne_force_meter_value(x: TonneForceMeter) -> Float {
  x.value
}

// ── to base (newton-meter) ──

pub fn kilonewton_meter_to_newton_meter(x: KilonewtonMeter) -> NewtonMeter {
  NewtonMeter(x.value *. kilonewton_meter_factor)
}

pub fn kilogram_force_meter_to_newton_meter(
  x: KilogramForceMeter,
) -> NewtonMeter {
  NewtonMeter(x.value *. kilogram_force_meter_factor)
}

pub fn tonne_force_meter_to_newton_meter(x: TonneForceMeter) -> NewtonMeter {
  NewtonMeter(x.value *. tonne_force_meter_factor)
}

// ── from base (newton-meter) ──

pub fn newton_meter_to_kilonewton_meter(x: NewtonMeter) -> KilonewtonMeter {
  KilonewtonMeter(x.value /. kilonewton_meter_factor)
}

pub fn newton_meter_to_kilogram_force_meter(
  x: NewtonMeter,
) -> KilogramForceMeter {
  KilogramForceMeter(x.value /. kilogram_force_meter_factor)
}

pub fn newton_meter_to_tonne_force_meter(x: NewtonMeter) -> TonneForceMeter {
  TonneForceMeter(x.value /. tonne_force_meter_factor)
}

// ── arithmetic on the base unit ──

/// Add two moments.
pub fn add(a: NewtonMeter, b: NewtonMeter) -> NewtonMeter {
  NewtonMeter(a.value +. b.value)
}

/// Subtract `b` from `a`.
pub fn subtract(a: NewtonMeter, b: NewtonMeter) -> NewtonMeter {
  NewtonMeter(a.value -. b.value)
}

/// Scale a moment by a dimensionless factor.
pub fn scale(a: NewtonMeter, factor: Float) -> NewtonMeter {
  NewtonMeter(a.value *. factor)
}
