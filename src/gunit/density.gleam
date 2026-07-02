//// Mass density units — opaque newtype per display unit (Approach 1),
//// mirroring `gunit/length`.
////
//// Distinct opaque types `KgPerMmCubed`, `TonPerMCubed`, `KgPerMCubed`.
//// Passing one where another is expected is a compile error. The canonical
//// base is `KgPerMCubed` (kg/m3, SI); arithmetic converts to the base,
//// computes, and converts back. Every factor is golden-tested.
////
//// NOTE: this module carries only conversion factors, not material reference
//// values (e.g. steel density) — those belong in the consuming application.

// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Cong Phap <tinhza2000@gmail.com>

// ── factors: multiply a value in <unit> by FACTOR to get kg/m3 ──

const kg_per_mm_cubed_factor = 1_000_000_000.0

const ton_per_m_cubed_factor = 1000.0

// ── opaque types ──

/// Mass density in kilograms per cubic millimeter.
pub opaque type KgPerMmCubed {
  KgPerMmCubed(value: Float)
}

/// Mass density in metric tonnes per cubic meter (1 t/m3 = 1000 kg/m3).
pub opaque type TonPerMCubed {
  TonPerMCubed(value: Float)
}

/// Mass density in kilograms per cubic meter. SI canonical base.
pub opaque type KgPerMCubed {
  KgPerMCubed(value: Float)
}

// ── constructors ──

pub fn kg_per_mm_cubed(v: Float) -> KgPerMmCubed {
  KgPerMmCubed(v)
}

pub fn ton_per_m_cubed(v: Float) -> TonPerMCubed {
  TonPerMCubed(v)
}

pub fn kg_per_m_cubed(v: Float) -> KgPerMCubed {
  KgPerMCubed(v)
}

// ── extractors (raw Float in that unit) ──

pub fn kg_per_mm_cubed_value(x: KgPerMmCubed) -> Float {
  x.value
}

pub fn ton_per_m_cubed_value(x: TonPerMCubed) -> Float {
  x.value
}

pub fn kg_per_m_cubed_value(x: KgPerMCubed) -> Float {
  x.value
}

// ── to base (kg/m3) ──

pub fn kg_per_mm_cubed_to_kg_per_m_cubed(x: KgPerMmCubed) -> KgPerMCubed {
  KgPerMCubed(x.value *. kg_per_mm_cubed_factor)
}

pub fn ton_per_m_cubed_to_kg_per_m_cubed(x: TonPerMCubed) -> KgPerMCubed {
  KgPerMCubed(x.value *. ton_per_m_cubed_factor)
}

// ── from base (kg/m3) ──

pub fn kg_per_m_cubed_to_kg_per_mm_cubed(x: KgPerMCubed) -> KgPerMmCubed {
  KgPerMmCubed(x.value /. kg_per_mm_cubed_factor)
}

pub fn kg_per_m_cubed_to_ton_per_m_cubed(x: KgPerMCubed) -> TonPerMCubed {
  TonPerMCubed(x.value /. ton_per_m_cubed_factor)
}

// ── arithmetic on the base unit (compute here; label at the edges) ──

/// Add two densities.
pub fn add(a: KgPerMCubed, b: KgPerMCubed) -> KgPerMCubed {
  KgPerMCubed(a.value +. b.value)
}

/// Subtract `b` from `a`.
pub fn subtract(a: KgPerMCubed, b: KgPerMCubed) -> KgPerMCubed {
  KgPerMCubed(a.value -. b.value)
}

/// Scale a density by a dimensionless factor.
pub fn scale(a: KgPerMCubed, factor: Float) -> KgPerMCubed {
  KgPerMCubed(a.value *. factor)
}
