//// Generated from Rust unit declarations. Do not edit.

// SPDX-FileCopyrightText: Cong Phap <phapnnc@daidung.vn>
// SPDX-License-Identifier: LicenseRef-Proprietary

import gleam/dynamic/decode

/// Finite nonnegative byte-base information quantity; fractions are permitted.
pub opaque type Bytes {
  Bytes(value: Float)
}

pub type QuantityError {
  NonFinite
  Negative
}

const maximum_float = 1.7976931348623157e308

/// Construct from byte base; refuse negative and nonfinite quantities.
pub fn bytes(value: Float) -> Result(Bytes, QuantityError) {
  case value -. value == 0.0 {
    False -> Error(NonFinite)
    True ->
      case value <. 0.0 {
        True -> Error(Negative)
        False -> Ok(Bytes(value))
      }
  }
}

/// Extract bytes only at a serialization or presentation boundary.
pub fn value(quantity: Bytes) -> Float {
  quantity.value
}

/// Decode a byte-base number through the same checked constructor.
pub fn decoder() -> decode.Decoder(Bytes) {
  use input <- decode.then(decode.float)
  case bytes(input) {
    Ok(quantity) -> decode.success(quantity)
    Error(_) -> decode.failure(Bytes(0.0), "finite nonnegative bytes")
  }
}

/// Construct from bytes; refuse negative, nonfinite or overflowing input.
pub fn from_bytes(input: Float) -> Result(Bytes, QuantityError) {
  case bytes(input) {
    Error(error) -> Error(error)
    Ok(_) ->
      case input >. maximum_float /. 1.0 {
        True -> Error(NonFinite)
        False -> bytes(input *. 1.0)
      }
  }
}

/// Convert to bytes at a presentation boundary.
pub fn to_bytes(quantity: Bytes) -> Float {
  quantity.value /. 1.0
}

/// Construct from kibibytes; refuse negative, nonfinite or overflowing input.
pub fn from_kibibytes(input: Float) -> Result(Bytes, QuantityError) {
  case bytes(input) {
    Error(error) -> Error(error)
    Ok(_) ->
      case input >. maximum_float /. 1024.0 {
        True -> Error(NonFinite)
        False -> bytes(input *. 1024.0)
      }
  }
}

/// Convert to kibibytes at a presentation boundary.
pub fn to_kibibytes(quantity: Bytes) -> Float {
  quantity.value /. 1024.0
}

/// Construct from mebibytes; refuse negative, nonfinite or overflowing input.
pub fn from_mebibytes(input: Float) -> Result(Bytes, QuantityError) {
  case bytes(input) {
    Error(error) -> Error(error)
    Ok(_) ->
      case input >. maximum_float /. 1_048_576.0 {
        True -> Error(NonFinite)
        False -> bytes(input *. 1_048_576.0)
      }
  }
}

/// Convert to mebibytes at a presentation boundary.
pub fn to_mebibytes(quantity: Bytes) -> Float {
  quantity.value /. 1_048_576.0
}

/// Construct from gibibytes; refuse negative, nonfinite or overflowing input.
pub fn from_gibibytes(input: Float) -> Result(Bytes, QuantityError) {
  case bytes(input) {
    Error(error) -> Error(error)
    Ok(_) ->
      case input >. maximum_float /. 1_073_741_824.0 {
        True -> Error(NonFinite)
        False -> bytes(input *. 1_073_741_824.0)
      }
  }
}

/// Convert to gibibytes at a presentation boundary.
pub fn to_gibibytes(quantity: Bytes) -> Float {
  quantity.value /. 1_073_741_824.0
}

/// Construct from tebibytes; refuse negative, nonfinite or overflowing input.
pub fn from_tebibytes(input: Float) -> Result(Bytes, QuantityError) {
  case bytes(input) {
    Error(error) -> Error(error)
    Ok(_) ->
      case input >. maximum_float /. 1_099_511_627_776.0 {
        True -> Error(NonFinite)
        False -> bytes(input *. 1_099_511_627_776.0)
      }
  }
}

/// Convert to tebibytes at a presentation boundary.
pub fn to_tebibytes(quantity: Bytes) -> Float {
  quantity.value /. 1_099_511_627_776.0
}
