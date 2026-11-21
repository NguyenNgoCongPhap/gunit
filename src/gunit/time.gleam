//// Time units — opaque newtype per display unit (Approach 1).
////
//// Distinct opaque types `Second` and `Millisecond`. Passing one where
//// another is expected is a compile error.
////
//// Arithmetic is provided on the canonical base unit (`Second`). The factor
//// is golden-tested.

// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Cong Phap <tinhza2000@gmail.com>

// ── factor: multiply a value in milliseconds by this to get seconds ──

const millisecond_factor = 0.001

// ── factors: multiply a value in minutes, hours or days by these to get seconds (SI-accepted units, BIPM SI Brochure Table 8) ──

const minute_factor = 60.0

const hour_factor = 3600.0

const day_factor = 86_400.0

// ── opaque types ──

/// Time in seconds. SI canonical base.
pub opaque type Second {
  Second(value: Float)
}

/// Time in milliseconds.
pub opaque type Millisecond {
  Millisecond(value: Float)
}

/// Time in minutes.
pub opaque type Minute {
  Minute(value: Float)
}

/// Time in hours.
pub opaque type Hour {
  Hour(value: Float)
}

/// Time in days of exactly 86 400 s; never a calendar day.
pub opaque type Day {
  Day(value: Float)
}

// ── constructors ──

pub fn second(v: Float) -> Second {
  Second(v)
}

pub fn millisecond(v: Float) -> Millisecond {
  Millisecond(v)
}

pub fn minute(v: Float) -> Minute {
  Minute(v)
}

pub fn hour(v: Float) -> Hour {
  Hour(v)
}

pub fn day(v: Float) -> Day {
  Day(v)
}

// ── extractors ──

pub fn second_value(x: Second) -> Float {
  x.value
}

pub fn millisecond_value(x: Millisecond) -> Float {
  x.value
}

pub fn minute_value(x: Minute) -> Float {
  x.value
}

pub fn hour_value(x: Hour) -> Float {
  x.value
}

pub fn day_value(x: Day) -> Float {
  x.value
}

// ── conversions ──

pub fn millisecond_to_second(x: Millisecond) -> Second {
  Second(x.value *. millisecond_factor)
}

pub fn second_to_millisecond(x: Second) -> Millisecond {
  Millisecond(x.value /. millisecond_factor)
}

pub fn minute_to_second(x: Minute) -> Second {
  Second(x.value *. minute_factor)
}

pub fn second_to_minute(x: Second) -> Minute {
  Minute(x.value /. minute_factor)
}

pub fn hour_to_second(x: Hour) -> Second {
  Second(x.value *. hour_factor)
}

pub fn second_to_hour(x: Second) -> Hour {
  Hour(x.value /. hour_factor)
}

pub fn day_to_second(x: Day) -> Second {
  Second(x.value *. day_factor)
}

pub fn second_to_day(x: Second) -> Day {
  Day(x.value /. day_factor)
}

// ── arithmetic on the base unit ──

/// Add two times.
pub fn add(a: Second, b: Second) -> Second {
  Second(a.value +. b.value)
}

/// Subtract `b` from `a`.
pub fn subtract(a: Second, b: Second) -> Second {
  Second(a.value -. b.value)
}

/// Scale a time by a dimensionless factor.
pub fn scale(a: Second, factor: Float) -> Second {
  Second(a.value *. factor)
}
