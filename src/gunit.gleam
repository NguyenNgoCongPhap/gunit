//// gunit — compile-time unit-label safety for engineering values.
////
//// This root module is documentation only. Import the unit families directly:
////
////   import gunit/length    // Millimeter, Centimeter, Meter
////   import gunit/force      // Newton, Kilonewton, Meganewton, KilogramForce, TonneForce
////   import gunit/pressure   // Pascal, Kilopascal, Megapascal, Gigapascal, KgfPerCm2
////   import gunit/moment     // NewtonMeter, KilonewtonMeter, KilogramForceMeter, TonneForceMeter
////   import gunit/angle      // Radian, Degree
////
//// Each unit is a DISTINCT opaque type, so the compiler rejects passing one
//// where another is expected — catching the "mm used as m" / "kPa used as MPa"
//// class of bug at compile time. Scope is SI plus a few gravitational-metric
//// units (kgf, tonne-force, kgf/cm2). It is *label* safety, not dimensional
//// analysis — see README.md for the rationale and the maintenance policy.

// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Cong Phap <tinhza2000@gmail.com>

/// The package name. Handy for about-screens / diagnostics.
pub const name = "gunit"
