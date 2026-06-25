//// Golden tests pinning every conversion factor in BOTH directions (forward
//// `*_to_base` and inverse `base_to_*`). Each expected value follows the factor
//// defined and cited in the corresponding `src/gunit/*` module (NIST SP 811 /
//// ISO 80000).
////
//// A wrong factor or a typo'd divisor here is exactly the silent bug this
//// library exists to prevent. Each test drives the SAME conversion path the
//// library exposes (not a duplicated constant), so a regression in the real
//// code fails right here.

// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Cong Phap <tinhza2000@gmail.com>

import gleam/float
import gleeunit
import gleeunit/should
import gunit/angle
import gunit/area
import gunit/force
import gunit/length
import gunit/mass
import gunit/moment
import gunit/pressure

pub fn main() {
  gleeunit.main()
}

/// True when two floats agree within a tight relative tolerance.
fn close(actual: Float, expected: Float) -> Bool {
  let tol = 1.0e-12 +. float.absolute_value(expected) *. 1.0e-12
  float.absolute_value(actual -. expected) <. tol
}

// ── LENGTH (base: meter) ───────────────────────────────────────────────────

pub fn millimeter_forward_test() {
  // 1 mm = 0.001 m (SI).
  length.millimeter(1.0)
  |> length.millimeter_to_meter
  |> length.meter_value
  |> close(0.001)
  |> should.be_true
}

pub fn millimeter_inverse_test() {
  // 0.001 m = 1 mm.
  length.meter(0.001)
  |> length.meter_to_millimeter
  |> length.millimeter_value
  |> close(1.0)
  |> should.be_true
}

pub fn centimeter_forward_test() {
  // 1 cm = 0.01 m (SI).
  length.centimeter(1.0)
  |> length.centimeter_to_meter
  |> length.meter_value
  |> close(0.01)
  |> should.be_true
}

pub fn centimeter_inverse_test() {
  // 0.01 m = 1 cm.
  length.meter(0.01)
  |> length.meter_to_centimeter
  |> length.centimeter_value
  |> close(1.0)
  |> should.be_true
}

pub fn length_round_trip_test() {
  // mm -> m -> mm returns the original.
  let original = 6000.0
  length.millimeter(original)
  |> length.millimeter_to_meter
  |> length.meter_to_millimeter
  |> length.millimeter_value
  |> close(original)
  |> should.be_true
}

pub fn length_arithmetic_test() {
  // (2 m + 3 m) scaled by 1.5 = 7.5 m.
  length.add(length.meter(2.0), length.meter(3.0))
  |> length.scale(1.5)
  |> length.meter_value
  |> close(7.5)
  |> should.be_true
}

// ── FORCE (base: newton) ───────────────────────────────────────────────────

pub fn kilonewton_forward_test() {
  // 1 kN = 1000 N.
  force.kilonewton(1.0)
  |> force.kilonewton_to_newton
  |> force.newton_value
  |> close(1000.0)
  |> should.be_true
}

pub fn kilonewton_inverse_test() {
  // 1000 N = 1 kN.
  force.newton(1000.0)
  |> force.newton_to_kilonewton
  |> force.kilonewton_value
  |> close(1.0)
  |> should.be_true
}

pub fn meganewton_forward_test() {
  // 1 MN = 1 000 000 N.
  force.meganewton(1.0)
  |> force.meganewton_to_newton
  |> force.newton_value
  |> close(1_000_000.0)
  |> should.be_true
}

pub fn meganewton_inverse_test() {
  force.newton(1_000_000.0)
  |> force.newton_to_meganewton
  |> force.meganewton_value
  |> close(1.0)
  |> should.be_true
}

pub fn kilogram_force_forward_test() {
  // 1 kgf = 9.80665 N (standard gravity g0, exact by definition).
  force.kilogram_force(1.0)
  |> force.kilogram_force_to_newton
  |> force.newton_value
  |> close(9.80665)
  |> should.be_true
}

pub fn kilogram_force_inverse_test() {
  force.newton(9.80665)
  |> force.newton_to_kilogram_force
  |> force.kilogram_force_value
  |> close(1.0)
  |> should.be_true
}

pub fn tonne_force_forward_test() {
  // 1 tonne-force = 1000 kgf = 9806.65 N.
  force.tonne_force(1.0)
  |> force.tonne_force_to_newton
  |> force.newton_value
  |> close(9806.65)
  |> should.be_true
}

pub fn tonne_force_inverse_test() {
  force.newton(9806.65)
  |> force.newton_to_tonne_force
  |> force.tonne_force_value
  |> close(1.0)
  |> should.be_true
}

pub fn force_arithmetic_test() {
  // 3 N + 4 N - 2 N = 5 N.
  force.subtract(
    force.add(force.newton(3.0), force.newton(4.0)),
    force.newton(2.0),
  )
  |> force.newton_value
  |> close(5.0)
  |> should.be_true
}

// ── PRESSURE (base: pascal) ────────────────────────────────────────────────

pub fn kilopascal_forward_test() {
  // 1 kPa = 1000 Pa.
  pressure.kilopascal(1.0)
  |> pressure.kilopascal_to_pascal
  |> pressure.pascal_value
  |> close(1000.0)
  |> should.be_true
}

pub fn kilopascal_inverse_test() {
  pressure.pascal(1000.0)
  |> pressure.pascal_to_kilopascal
  |> pressure.kilopascal_value
  |> close(1.0)
  |> should.be_true
}

pub fn megapascal_forward_test() {
  // 1 MPa = 1 000 000 Pa = 1 N/mm2.
  pressure.megapascal(1.0)
  |> pressure.megapascal_to_pascal
  |> pressure.pascal_value
  |> close(1_000_000.0)
  |> should.be_true
}

pub fn megapascal_inverse_test() {
  pressure.pascal(1_000_000.0)
  |> pressure.pascal_to_megapascal
  |> pressure.megapascal_value
  |> close(1.0)
  |> should.be_true
}

pub fn gigapascal_forward_test() {
  // 1 GPa = 1e9 Pa.
  pressure.gigapascal(1.0)
  |> pressure.gigapascal_to_pascal
  |> pressure.pascal_value
  |> close(1_000_000_000.0)
  |> should.be_true
}

pub fn gigapascal_inverse_test() {
  pressure.pascal(1_000_000_000.0)
  |> pressure.pascal_to_gigapascal
  |> pressure.gigapascal_value
  |> close(1.0)
  |> should.be_true
}

pub fn kgf_per_cm2_forward_test() {
  // 1 kgf/cm2 = 98066.5 Pa = 0.0980665 MPa.
  pressure.kgf_per_cm2(1.0)
  |> pressure.kgf_per_cm2_to_pascal
  |> pressure.pascal_value
  |> close(98_066.5)
  |> should.be_true
}

pub fn kgf_per_cm2_inverse_test() {
  pressure.pascal(98_066.5)
  |> pressure.pascal_to_kgf_per_cm2
  |> pressure.kgf_per_cm2_value
  |> close(1.0)
  |> should.be_true
}

pub fn kgf_per_cm2_cross_module_anchor_test() {
  // Consistency anchor: kgf/cm2 must equal (kgf force) / (cm x cm area),
  // derived through the force and length modules. Catches a g0 drift in ANY of
  // the three modules.
  let kgf_in_n =
    force.kilogram_force(1.0)
    |> force.kilogram_force_to_newton
    |> force.newton_value
  let cm_in_m =
    length.centimeter(1.0) |> length.centimeter_to_meter |> length.meter_value
  let expected_pa = kgf_in_n /. { cm_in_m *. cm_in_m }
  pressure.kgf_per_cm2(1.0)
  |> pressure.kgf_per_cm2_to_pascal
  |> pressure.pascal_value
  |> close(expected_pa)
  |> should.be_true
}

pub fn pressure_scale_test() {
  // 250 kPa scaled by 4 = 1 MPa = 1 000 000 Pa.
  pressure.kilopascal(250.0)
  |> pressure.kilopascal_to_pascal
  |> pressure.scale(4.0)
  |> pressure.pascal_value
  |> close(1_000_000.0)
  |> should.be_true
}

// ── MOMENT (base: newton-meter) ────────────────────────────────────────────

pub fn kilonewton_meter_forward_test() {
  // 1 kN.m = 1000 N.m.
  moment.kilonewton_meter(1.0)
  |> moment.kilonewton_meter_to_newton_meter
  |> moment.newton_meter_value
  |> close(1000.0)
  |> should.be_true
}

pub fn kilonewton_meter_inverse_test() {
  moment.newton_meter(1000.0)
  |> moment.newton_meter_to_kilonewton_meter
  |> moment.kilonewton_meter_value
  |> close(1.0)
  |> should.be_true
}

pub fn kilogram_force_meter_forward_test() {
  // 1 kgf.m = 9.80665 N.m.
  moment.kilogram_force_meter(1.0)
  |> moment.kilogram_force_meter_to_newton_meter
  |> moment.newton_meter_value
  |> close(9.80665)
  |> should.be_true
}

pub fn kilogram_force_meter_inverse_test() {
  moment.newton_meter(9.80665)
  |> moment.newton_meter_to_kilogram_force_meter
  |> moment.kilogram_force_meter_value
  |> close(1.0)
  |> should.be_true
}

pub fn tonne_force_meter_forward_test() {
  // 1 tonne-force.m = 9806.65 N.m.
  moment.tonne_force_meter(1.0)
  |> moment.tonne_force_meter_to_newton_meter
  |> moment.newton_meter_value
  |> close(9806.65)
  |> should.be_true
}

pub fn tonne_force_meter_inverse_test() {
  moment.newton_meter(9806.65)
  |> moment.newton_meter_to_tonne_force_meter
  |> moment.tonne_force_meter_value
  |> close(1.0)
  |> should.be_true
}

pub fn moment_add_test() {
  // 120 kN.m + 80 kN.m = 200 kN.m = 200000 N.m.
  moment.add(
    moment.kilonewton_meter(120.0) |> moment.kilonewton_meter_to_newton_meter,
    moment.kilonewton_meter(80.0) |> moment.kilonewton_meter_to_newton_meter,
  )
  |> moment.newton_meter_value
  |> close(200_000.0)
  |> should.be_true
}

// ── ANGLE (base: radian) ───────────────────────────────────────────────────

pub fn degree_forward_test() {
  // 1 deg = pi/180 rad.
  angle.degree(1.0)
  |> angle.degree_to_radian
  |> angle.radian_value
  |> close(0.017453292519943295)
  |> should.be_true
}

pub fn degree_inverse_test() {
  angle.radian(0.017453292519943295)
  |> angle.radian_to_degree
  |> angle.degree_value
  |> close(1.0)
  |> should.be_true
}

pub fn degree_half_turn_test() {
  // 180 deg = pi rad.
  let pi = 3.141592653589793
  angle.degree(180.0)
  |> angle.degree_to_radian
  |> angle.radian_value
  |> close(pi)
  |> should.be_true
}

pub fn angle_round_trip_test() {
  let original = 33.7
  angle.degree(original)
  |> angle.degree_to_radian
  |> angle.radian_to_degree
  |> angle.degree_value
  |> close(original)
  |> should.be_true
}

pub fn angle_add_test() {
  // 30 deg + 60 deg = 90 deg = pi/2 rad.
  let half_pi = 1.5707963267948966
  angle.add(
    angle.degree(30.0) |> angle.degree_to_radian,
    angle.degree(60.0) |> angle.degree_to_radian,
  )
  |> angle.radian_value
  |> close(half_pi)
  |> should.be_true
}

pub fn force_scale_test() {
  // 10 N x 2.5 = 25 N.
  force.scale(force.newton(10.0), 2.5)
  |> force.newton_value
  |> close(25.0)
  |> should.be_true
}

pub fn length_subtract_test() {
  // 5 m - 2 m = 3 m.
  length.subtract(length.meter(5.0), length.meter(2.0))
  |> length.meter_value
  |> close(3.0)
  |> should.be_true
}

pub fn pressure_add_subtract_test() {
  // (100 + 50 - 30) Pa = 120 Pa.
  pressure.subtract(
    pressure.add(pressure.pascal(100.0), pressure.pascal(50.0)),
    pressure.pascal(30.0),
  )
  |> pressure.pascal_value
  |> close(120.0)
  |> should.be_true
}

pub fn moment_subtract_scale_test() {
  // (10 - 4) N.m x 2 = 12 N.m.
  moment.scale(
    moment.subtract(moment.newton_meter(10.0), moment.newton_meter(4.0)),
    2.0,
  )
  |> moment.newton_meter_value
  |> close(12.0)
  |> should.be_true
}

pub fn angle_subtract_scale_test() {
  // (3 - 1) rad x 0.5 = 1 rad.
  angle.scale(angle.subtract(angle.radian(3.0), angle.radian(1.0)), 0.5)
  |> angle.radian_value
  |> close(1.0)
  |> should.be_true
}

// ── AREA (base: square meter) ──────────────────────────────────────────────

pub fn square_millimeter_forward_test() {
  // 1 mm2 = (0.001 m)^2 = 1e-6 m2.
  area.square_millimeter(1.0)
  |> area.square_millimeter_to_square_meter
  |> area.square_meter_value
  |> close(0.000001)
  |> should.be_true
}

pub fn square_millimeter_inverse_test() {
  area.square_meter(0.000001)
  |> area.square_meter_to_square_millimeter
  |> area.square_millimeter_value
  |> close(1.0)
  |> should.be_true
}

pub fn square_centimeter_forward_test() {
  // 1 cm2 = (0.01 m)^2 = 1e-4 m2.
  area.square_centimeter(1.0)
  |> area.square_centimeter_to_square_meter
  |> area.square_meter_value
  |> close(0.0001)
  |> should.be_true
}

pub fn square_centimeter_inverse_test() {
  area.square_meter(0.0001)
  |> area.square_meter_to_square_centimeter
  |> area.square_centimeter_value
  |> close(1.0)
  |> should.be_true
}

pub fn area_cross_module_anchor_test() {
  // 1 cm2 must equal (1 cm in m)^2, derived through the length module — catches
  // a drift between the area factor and the length factor it squares.
  let cm_in_m =
    length.centimeter(1.0) |> length.centimeter_to_meter |> length.meter_value
  area.square_centimeter(1.0)
  |> area.square_centimeter_to_square_meter
  |> area.square_meter_value
  |> close(cm_in_m *. cm_in_m)
  |> should.be_true
}

pub fn area_arithmetic_test() {
  // (2 + 3) m2 scaled by 1.5 = 7.5 m2.
  area.add(area.square_meter(2.0), area.square_meter(3.0))
  |> area.scale(1.5)
  |> area.square_meter_value
  |> close(7.5)
  |> should.be_true
}

// ── MASS (base: kilogram) ──────────────────────────────────────────────────

pub fn gram_forward_test() {
  // 1 g = 0.001 kg.
  mass.gram(1.0)
  |> mass.gram_to_kilogram
  |> mass.kilogram_value
  |> close(0.001)
  |> should.be_true
}

pub fn gram_inverse_test() {
  mass.kilogram(0.001)
  |> mass.kilogram_to_gram
  |> mass.gram_value
  |> close(1.0)
  |> should.be_true
}

pub fn tonne_forward_test() {
  // 1 t = 1000 kg (metric tonne).
  mass.tonne(1.0)
  |> mass.tonne_to_kilogram
  |> mass.kilogram_value
  |> close(1000.0)
  |> should.be_true
}

pub fn tonne_inverse_test() {
  mass.kilogram(1000.0)
  |> mass.kilogram_to_tonne
  |> mass.tonne_value
  |> close(1.0)
  |> should.be_true
}

pub fn mass_tonne_gram_anchor_test() {
  // 1 tonne = 1e6 g, reconciled through the kilogram base.
  let g_in_kg =
    mass.gram(1_000_000.0) |> mass.gram_to_kilogram |> mass.kilogram_value
  mass.tonne(1.0)
  |> mass.tonne_to_kilogram
  |> mass.kilogram_value
  |> close(g_in_kg)
  |> should.be_true
}

pub fn mass_arithmetic_test() {
  // (1500 + 500 - 1000) kg scaled by 2 = 2000 kg.
  mass.scale(
    mass.subtract(
      mass.add(mass.kilogram(1500.0), mass.kilogram(500.0)),
      mass.kilogram(1000.0),
    ),
    2.0,
  )
  |> mass.kilogram_value
  |> close(2000.0)
  |> should.be_true
}
