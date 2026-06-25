//// Mass units — opaque newtype per display unit (Approach 1), mirroring
//// `gunit/length`.
////
//// Distinct opaque types `Gram`, `Kilogram`, `Tonne`. Passing one where
//// another is expected is a compile error. The canonical base is `Kilogram`;
//// arithmetic converts to the base, computes, and converts back. Every factor
//// is golden-tested.
////
//// NOTE: these are units of MASS, distinct from the gravitational-metric FORCE
//// units in `gunit/force` (`KilogramForce`, `TonneForce`). A `Tonne` here is
//// the metric tonne = 1000 kg of mass, not a tonne-force.

// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Cong Phap <tinhza2000@gmail.com>

// ── factors: multiply a value in <unit> by FACTOR to get kilograms ──

const gram_factor = 0.001

const tonne_factor = 1000.0

// ── opaque types ──

/// Mass in grams.
pub opaque type Gram {
  Gram(value: Float)
}

/// Mass in kilograms. SI canonical base.
pub opaque type Kilogram {
  Kilogram(value: Float)
}

/// Mass in metric tonnes (1 t = 1000 kg).
pub opaque type Tonne {
  Tonne(value: Float)
}

// ── constructors ──

pub fn gram(v: Float) -> Gram {
  Gram(v)
}

pub fn kilogram(v: Float) -> Kilogram {
  Kilogram(v)
}

pub fn tonne(v: Float) -> Tonne {
  Tonne(v)
}

// ── extractors (raw Float in that unit) ──

pub fn gram_value(x: Gram) -> Float {
  x.value
}

pub fn kilogram_value(x: Kilogram) -> Float {
  x.value
}

pub fn tonne_value(x: Tonne) -> Float {
  x.value
}

// ── to base (kilogram) ──

pub fn gram_to_kilogram(x: Gram) -> Kilogram {
  Kilogram(x.value *. gram_factor)
}

pub fn tonne_to_kilogram(x: Tonne) -> Kilogram {
  Kilogram(x.value *. tonne_factor)
}

// ── from base (kilogram) ──

pub fn kilogram_to_gram(x: Kilogram) -> Gram {
  Gram(x.value /. gram_factor)
}

pub fn kilogram_to_tonne(x: Kilogram) -> Tonne {
  Tonne(x.value /. tonne_factor)
}

// ── arithmetic on the base unit (compute here; label at the edges) ──

/// Add two masses.
pub fn add(a: Kilogram, b: Kilogram) -> Kilogram {
  Kilogram(a.value +. b.value)
}

/// Subtract `b` from `a`.
pub fn subtract(a: Kilogram, b: Kilogram) -> Kilogram {
  Kilogram(a.value -. b.value)
}

/// Scale a mass by a dimensionless factor.
pub fn scale(a: Kilogram, factor: Float) -> Kilogram {
  Kilogram(a.value *. factor)
}
