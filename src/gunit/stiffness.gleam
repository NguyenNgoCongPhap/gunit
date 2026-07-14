//// Spring stiffness — opaque newtype per display unit.
////
//// Two brands with unrelated dimensions, so there is no conversion between
//// them by construction:
////   - `KnPerM`    — translational stiffness, force per unit translation.
////   - `KnMPerRad` — rotational stiffness, moment per unit rotation.
////
//// Partial-fixity joint releases carry both (DOFs 1-3 translate, 4-6 rotate);
//// passing one where the other is expected is a compile error here.

// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Cong Phap <tinhza2000@gmail.com>

// ── opaque types ──

/// Translational spring stiffness in kN/m.
pub opaque type KnPerM {
  KnPerM(value: Float)
}

/// Rotational spring stiffness in kN*m/rad.
pub opaque type KnMPerRad {
  KnMPerRad(value: Float)
}

// ── constructors ──

pub fn kn_per_m(v: Float) -> KnPerM {
  KnPerM(v)
}

pub fn kn_m_per_rad(v: Float) -> KnMPerRad {
  KnMPerRad(v)
}

// ── extractors ──

pub fn kn_per_m_value(x: KnPerM) -> Float {
  x.value
}

pub fn kn_m_per_rad_value(x: KnMPerRad) -> Float {
  x.value
}
