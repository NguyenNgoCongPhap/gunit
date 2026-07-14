//// Dimensionless quantities — one opaque brand per engineering meaning.
////
//// All four share the same primitive `Float` and carry no conversion factor,
//// so what is being prevented here is not a unit mix-up but a MEANING mix-up:
//// a design-check ratio assigned into a modal-participation slot compiles
//// fine as a bare `Float` and is caught only by an engineer noticing the
//// number looks wrong.
////
//// Conventions:
////   - `Ratio`            — open-range design-check ratio (dc-ratio; 0..inf,
////                          in practice 0..1.5).
////   - `Slenderness`      — element slenderness (`KL/r`, `b/t`, `h/tw`).
////   - `Fraction`         — closed 0..1 range (utilization, normalized
////                          interaction).
////   - `ParticipationPct` — 0..100 modal participation percent.

// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Cong Phap <tinhza2000@gmail.com>

// ── opaque types ──

pub opaque type Ratio {
  Ratio(value: Float)
}

pub opaque type Slenderness {
  Slenderness(value: Float)
}

pub opaque type Fraction {
  Fraction(value: Float)
}

pub opaque type ParticipationPct {
  ParticipationPct(value: Float)
}

// ── constructors ──

pub fn ratio(v: Float) -> Ratio {
  Ratio(v)
}

pub fn slenderness(v: Float) -> Slenderness {
  Slenderness(v)
}

pub fn fraction(v: Float) -> Fraction {
  Fraction(v)
}

pub fn participation_pct(v: Float) -> ParticipationPct {
  ParticipationPct(v)
}

// ── extractors ──

pub fn ratio_value(x: Ratio) -> Float {
  x.value
}

pub fn slenderness_value(x: Slenderness) -> Float {
  x.value
}

pub fn fraction_value(x: Fraction) -> Float {
  x.value
}

pub fn participation_pct_value(x: ParticipationPct) -> Float {
  x.value
}
