use ollama_rs::{generation::tools::ToolFunctionInfo, re_exports::schemars::json_schema};
use rand::RngExt;

use crate::{State, extensions::tool_function_info::ToolFunctionInfoExt};

use super::{Tool, calculate::format_number};

pub struct RandomNumberTool;

const MAX_COUNT: i64 = 50;
const MAX_DECIMALS: i64 = 10;

#[async_trait::async_trait]
impl Tool for RandomNumberTool {
    fn info(&self) -> ollama_rs::generation::tools::ToolInfo {
        ToolFunctionInfo {
            name: "random_number".to_string(),
            description: "Generates one or more random numbers within an inclusive range. Use this \
                 whenever you need randomness, like dice rolls, picking a winner or a random fact, \
                 instead of pretending you rolled something yourself."
                .to_string(),
            parameters: json_schema!({
                "type":"object",
                "properties": {
                    "min": {
                        "type": "number",
                        "description": "Lower bound of the range, included. Defaults to 0."
                    },
                    "max": {
                        "type": "number",
                        "description": "Upper bound of the range, included. Defaults to 100."
                    },
                    "decimals": {
                        "type": "integer",
                        "description": "Number of decimal places. 0 or omitted gives whole numbers. Defaults to 0."
                    },
                    "count": {
                        "type": "integer",
                        "description": "How many numbers to generate, from 1 to 50. Defaults to 1."
                    }
                },
                "required": []
            }),
        }
        .into_tool_info()
    }

    async fn execute(&self, _state: State, arguments: serde_json::Value) -> String {
        let get_number = |name: &str| arguments.get(name).and_then(|v| v.as_f64());
        let get_int = |name: &str| arguments.get(name).and_then(|v| v.as_i64());

        let min = get_number("min").unwrap_or(0.0);
        let max = get_number("max").unwrap_or(100.0);
        let decimals = get_int("decimals").unwrap_or(0);
        let count = get_int("count").unwrap_or(1);

        match message(min, max, decimals, count) {
            Ok(message) => message,
            Err(e) => format!("Error: {}", e),
        }
    }
}

/// Pulls `count` numbers out of the range and wraps them in a sentence the
/// model can pass on.
fn message(min: f64, max: f64, decimals: i64, count: i64) -> Result<String, String> {
    let values = random_values(min, max, decimals, count)?;
    let bounds = format!("{} and {}", format_number(min), format_number(max));

    if count == 1 {
        Ok(format!("Random number between {}: {}", bounds, values[0]))
    } else {
        Ok(format!(
            "{} random numbers between {}: {}",
            count,
            bounds,
            values.join(", ")
        ))
    }
}

fn random_values(min: f64, max: f64, decimals: i64, count: i64) -> Result<Vec<String>, String> {
    if !min.is_finite() || !max.is_finite() {
        return Err("min and max must be finite numbers.".to_string());
    }
    if max < min {
        return Err("max must be greater than or equal to min.".to_string());
    }
    if !(1..=MAX_COUNT).contains(&count) {
        return Err(format!("count must be between 1 and {}.", MAX_COUNT));
    }
    if !(0..=MAX_DECIMALS).contains(&decimals) {
        return Err(format!("decimals must be between 0 and {}.", MAX_DECIMALS));
    }

    let mut rng = rand::rng();
    let mut values = Vec::with_capacity(count as usize);

    for _ in 0..count {
        values.push(if decimals == 0 {
            let low = min.ceil();
            let high = max.floor();
            if high < low {
                return Err(
                    "the range contains no whole number, set decimals to get a fraction instead."
                        .to_string(),
                );
            }
            format!("{}", rng.random_range(low as i64..=high as i64))
        } else {
            let scale = 10f64.powi(decimals as i32);
            let value = rng.random_range(min..=max);
            let value = ((value * scale).round() / scale).clamp(min, max);
            format!("{:.*}", decimals as usize, value)
        });
    }

    Ok(values)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn whole_numbers_stay_in_range() {
        for _ in 0..100 {
            let values = random_values(1.0, 6.0, 0, 1).unwrap();
            assert_eq!(values.len(), 1);
            let value: i64 = values[0].parse().unwrap();
            assert!((1..=6).contains(&value), "{} out of range", value);
        }
    }

    #[test]
    fn negative_and_zero_bounds() {
        let values = random_values(-10.0, -1.0, 0, 20).unwrap();
        assert_eq!(values.len(), 20);
        for value in &values {
            let value: i64 = value.parse().unwrap();
            assert!((-10..=-1).contains(&value), "{} out of range", value);
        }

        let values = random_values(0.0, 0.0, 0, 5).unwrap();
        assert!(values.iter().all(|v| v == "0"));
    }

    #[test]
    fn decimals_are_respected() {
        for _ in 0..100 {
            let values = random_values(0.0, 1.0, 2, 3).unwrap();
            assert_eq!(values.len(), 3);
            for value in &values {
                let places = value.split('.').nth(1).map(str::len).unwrap_or(0);
                assert_eq!(places, 2, "{} does not have 2 decimals", value);
                let parsed: f64 = value.parse().unwrap();
                assert!((0.0..=1.0).contains(&parsed));
            }
        }
    }

    #[test]
    fn fractional_range_needs_decimals() {
        assert!(random_values(0.5, 0.9, 0, 1).is_err());
        assert!(random_values(0.5, 0.9, 1, 1).is_ok());
    }

    #[test]
    fn invalid_arguments_error() {
        assert!(random_values(10.0, 1.0, 0, 1).is_err());
        assert!(random_values(0.0, 10.0, 0, 0).is_err());
        assert!(random_values(0.0, 10.0, 0, 51).is_err());
        assert!(random_values(0.0, 10.0, -1, 1).is_err());
        assert!(random_values(0.0, 10.0, 11, 1).is_err());
        assert!(random_values(f64::NAN, 10.0, 0, 1).is_err());
    }

    #[test]
    fn messages_describe_the_range() {
        let single = message(1.0, 6.0, 0, 1).unwrap();
        assert!(
            single.starts_with("Random number between 1 and 6: "),
            "{}",
            single
        );

        let many = message(0.0, 100.0, 0, 3).unwrap();
        assert!(
            many.starts_with("3 random numbers between 0 and 100: "),
            "{}",
            many
        );

        let floats = message(0.0, 1.5, 0, 1).unwrap();
        assert!(floats.contains("0 and 1.5"), "{}", floats);

        assert!(message(5.0, 1.0, 0, 1).is_err());
    }
}
