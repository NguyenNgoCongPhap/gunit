//// gunit — compile-time unit-label safety for engineering values.
////
//// This root module is documentation only. Import the unit families directly:
////
////   import gunit/length    // Millimeter, Centimeter, Meter, Inch, Foot
////   import gunit/area       // SquareMillimeter, SquareCentimeter, SquareMeter
////   import gunit/force      // Newton, Kilonewton, Meganewton, KilogramForce, TonneForce, PoundForce, KipForce
////   import gunit/pressure   // Pascal, Kilopascal, Megapascal, Gigapascal, KgfPerCm2
////   import gunit/moment     // NewtonMeter, KilonewtonMeter, KilogramForceMeter, TonneForceMeter
////   import gunit/mass       // Gram, Kilogram, Tonne
////   import gunit/angle      // Radian, Degree
////   import gunit/density    // KgPerMCubed, KgPerMmCubed, TonPerMCubed
////   import gunit/time       // Second, Millisecond
////   import gunit/inertia    // Mm4
////   import gunit/frequency  // Hz
////   import gunit/stiffness  // KnPerM, KnMPerRad
////   import gunit/dimensionless  // Ratio, Slenderness, Fraction, ParticipationPct
////
//// Each unit is a DISTINCT opaque type, so the compiler rejects passing one
//// where another is expected — catching the "mm used as m" / "kPa used as MPa"
//// class of bug at compile time. Scope is SI plus a few gravitational-metric
//// units (kgf, tonne-force, kgf/cm2) plus common US-customary units (lbf,
//// kip, in, ft). It is *label* safety, not dimensional analysis — see
//// README.md for the rationale and the maintenance policy.
////
//// A conversion ladder is NOT the price of admission. A family with one
//// display unit (`inertia`, `frequency`) or with none to convert between
//// (`stiffness`, `dimensionless`) belongs here too: the label is what the
//// consumer needs, and hosting it anywhere else means every consumer keeps a
//// private copy of it — which is precisely the drift this library exists to
//// end.

// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Cong Phap <tinhza2000@gmail.com>

/// The package name. Handy for about-screens / diagnostics.
pub const name = "gunit"
