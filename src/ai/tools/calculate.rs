use std::f64::consts::{E, PI, TAU};

use ollama_rs::{generation::tools::ToolFunctionInfo, re_exports::schemars::json_schema};

use crate::{State, extensions::tool_function_info::ToolFunctionInfoExt};

use super::Tool;

pub struct CalculateTool;

#[async_trait::async_trait]
impl Tool for CalculateTool {
    fn info(&self) -> ollama_rs::generation::tools::ToolInfo {
        ToolFunctionInfo {
            name: "calculate".to_string(),
            description: "Evaluates a mathematical expression and returns the result. Use this for \
                 any arithmetic instead of doing the math yourself. Supports +, -, *, /, % and ^, \
                 parentheses, decimals and scientific notation, the constants pi, tau and e, and \
                 the functions sqrt, cbrt, abs, round, floor, ceil, trunc, sign, exp, ln, log, \
                 log2, min, max and pow."
                .to_string(),
            parameters: json_schema!({
                "type":"object",
                "properties": {
                    "expression": {
                        "type": "string",
                        "description": "The math expression to evaluate, for example (2 + 3) * 4 or sqrt(2) * 100."
                    }
                },
                "required": ["expression"]
            }),
        }
        .into_tool_info()
    }

    async fn execute(&self, _state: State, arguments: serde_json::Value) -> String {
        let Some(expression) = arguments.get("expression").and_then(|v| v.as_str()) else {
            return "Error: missing required argument expression.".to_string();
        };

        match evaluate(expression) {
            Ok(result) => format!("{} = {}", expression.trim(), format_number(result)),
            Err(e) => format!("Error: {}", e),
        }
    }
}

/// Formats a result the way a calculator would: integers without a decimal
/// part, and floats trimmed of the noise floating point arithmetic leaves
/// behind (0.1 + 0.2 prints as 0.3 instead of 0.30000000000000004).
pub(super) fn format_number(value: f64) -> String {
    if value.is_nan() {
        return "NaN".to_string();
    }
    if value.is_infinite() {
        return if value > 0.0 {
            "Infinity".to_string()
        } else {
            "-Infinity".to_string()
        };
    }
    if value == 0.0 {
        return "0".to_string();
    }
    if value.fract() == 0.0 && value.abs() < 1e15 {
        return format!("{}", value as i64);
    }

    let formatted = format!("{:.10}", value);
    let trimmed = formatted.trim_end_matches('0').trim_end_matches('.');
    let rounds_to_zero = trimmed.parse::<f64>().is_ok_and(|v| v == 0.0);
    if trimmed.is_empty() || trimmed == "-" || rounds_to_zero {
        format!("{}", value)
    } else {
        trimmed.to_string()
    }
}

/// Rewrites characters people copy out of textbooks into the ascii the parser
/// understands.
fn normalize(expression: &str) -> String {
    let mut normalized = String::with_capacity(expression.len());
    for c in expression.chars() {
        match c {
            '×' | '·' => normalized.push('*'),
            '÷' => normalized.push('/'),
            '−' => normalized.push('-'),
            '（' => normalized.push('('),
            '）' => normalized.push(')'),
            'π' => normalized.push_str("pi"),
            _ => normalized.push(c),
        }
    }
    normalized
}

pub fn evaluate(expression: &str) -> Result<f64, String> {
    let chars: Vec<char> = normalize(expression).chars().collect();
    let mut parser = Parser {
        input: &chars,
        pos: 0,
    };

    parser.skip_whitespace();
    if parser.pos >= parser.input.len() {
        return Err("the expression is empty.".to_string());
    }

    let result = parser.parse_expression()?;

    parser.skip_whitespace();
    if parser.pos < parser.input.len() {
        return Err(format!(
            "unexpected '{}' at position {}.",
            parser.input[parser.pos],
            parser.pos + 1
        ));
    }

    if result.is_nan() {
        return Err("the expression is undefined, it has no real result.".to_string());
    }
    if !result.is_finite() {
        return Err("the expression does not evaluate to a finite number.".to_string());
    }

    Ok(result)
}

struct Parser<'a> {
    input: &'a [char],
    pos: usize,
}

impl Parser<'_> {
    fn peek(&self) -> Option<char> {
        self.input.get(self.pos).copied()
    }

    fn skip_whitespace(&mut self) {
        while matches!(self.peek(), Some(c) if c.is_whitespace()) {
            self.pos += 1;
        }
    }

    /// expression := term (('+' | '-') term)*
    fn parse_expression(&mut self) -> Result<f64, String> {
        let mut value = self.parse_term()?;

        loop {
            self.skip_whitespace();
            match self.peek() {
                Some('+') => {
                    self.pos += 1;
                    value += self.parse_term()?;
                }
                Some('-') => {
                    self.pos += 1;
                    value -= self.parse_term()?;
                }
                _ => break,
            }
        }

        Ok(value)
    }

    /// term := unary (('*' | '/' | '%') unary)*
    fn parse_term(&mut self) -> Result<f64, String> {
        let mut value = self.parse_unary()?;

        loop {
            self.skip_whitespace();
            let op = match self.peek() {
                Some(c) if c == '*' || c == '/' || c == '%' => c,
                _ => break,
            };
            self.pos += 1;

            let rhs = self.parse_unary()?;
            value = match op {
                '*' => value * rhs,
                '/' => {
                    if rhs == 0.0 {
                        return Err("division by zero.".to_string());
                    }
                    value / rhs
                }
                _ => {
                    if rhs == 0.0 {
                        return Err("division by zero.".to_string());
                    }
                    value % rhs
                }
            };
        }

        Ok(value)
    }

    /// unary := ('-' | '+') unary | power
    fn parse_unary(&mut self) -> Result<f64, String> {
        self.skip_whitespace();
        match self.peek() {
            Some('-') => {
                self.pos += 1;
                Ok(-self.parse_unary()?)
            }
            Some('+') => {
                self.pos += 1;
                self.parse_unary()
            }
            _ => self.parse_power(),
        }
    }

    /// power := primary ('^' unary)?  -- right associative, so 2^-3 works
    fn parse_power(&mut self) -> Result<f64, String> {
        let base = self.parse_primary()?;

        self.skip_whitespace();
        if self.peek() == Some('^') {
            self.pos += 1;
            let exponent = self.parse_unary()?;
            Ok(base.powf(exponent))
        } else {
            Ok(base)
        }
    }

    /// primary := '(' expression ')' | number | identifier ['(' args ')']
    fn parse_primary(&mut self) -> Result<f64, String> {
        self.skip_whitespace();

        match self.peek() {
            None => Err("unexpected end of expression.".to_string()),
            Some('(') => {
                self.pos += 1;
                let value = self.parse_expression()?;
                self.skip_whitespace();
                if self.peek() != Some(')') {
                    return Err(format!("expected ')' at position {}.", self.pos + 1));
                }
                self.pos += 1;
                Ok(value)
            }
            Some(c) if c.is_ascii_digit() || c == '.' => self.parse_number(),
            Some(c) if c.is_ascii_alphabetic() => self.parse_identifier(),
            Some(c) => Err(format!(
                "unexpected '{}' at position {}.",
                c,
                self.pos + 1
            )),
        }
    }

    fn parse_number(&mut self) -> Result<f64, String> {
        let start = self.pos;

        while matches!(self.peek(), Some(c) if c.is_ascii_digit()) {
            self.pos += 1;
        }
        if self.peek() == Some('.') {
            self.pos += 1;
            while matches!(self.peek(), Some(c) if c.is_ascii_digit()) {
                self.pos += 1;
            }
        }

        // Optional exponent, e.g. 1e-3. Only consumed when followed by digits
        // so that the constant `e` keeps working.
        if matches!(self.peek(), Some('e') | Some('E')) {
            let exponent_start = self.pos;
            self.pos += 1;
            if matches!(self.peek(), Some('+') | Some('-')) {
                self.pos += 1;
            }
            if matches!(self.peek(), Some(c) if c.is_ascii_digit()) {
                while matches!(self.peek(), Some(c) if c.is_ascii_digit()) {
                    self.pos += 1;
                }
            } else {
                self.pos = exponent_start;
            }
        }

        let text: String = self.input[start..self.pos].iter().collect();
        text.parse::<f64>()
            .map_err(|_| format!("'{}' is not a valid number.", text))
    }

    fn parse_identifier(&mut self) -> Result<f64, String> {
        let start = self.pos;
        while matches!(self.peek(), Some(c) if c.is_ascii_alphanumeric() || c == '_') {
            self.pos += 1;
        }
        let name: String = self.input[start..self.pos].iter().collect();
        let name = name.to_lowercase();

        self.skip_whitespace();
        if self.peek() != Some('(') {
            return match name.as_str() {
                "pi" => Ok(PI),
                "tau" => Ok(TAU),
                "e" => Ok(E),
                _ => Err(format!("'{}' is not a known constant.", name)),
            };
        }

        if !is_known_function(&name) {
            return Err(format!("'{}' is not a known function.", name));
        }
        self.pos += 1;

        let mut args = Vec::new();
        self.skip_whitespace();
        if self.peek() == Some(')') {
            self.pos += 1;
        } else {
            loop {
                args.push(self.parse_expression()?);
                self.skip_whitespace();
                match self.peek() {
                    Some(',') => self.pos += 1,
                    Some(')') => {
                        self.pos += 1;
                        break;
                    }
                    _ => {
                        return Err(format!(
                            "expected ',' or ')' at position {}.",
                            self.pos + 1
                        ));
                    }
                }
            }
        }

        call_function(&name, &args)
    }
}

fn is_known_function(name: &str) -> bool {
    matches!(
        name,
        "sqrt"
            | "cbrt"
            | "abs"
            | "round"
            | "floor"
            | "ceil"
            | "trunc"
            | "sign"
            | "exp"
            | "ln"
            | "log"
            | "log10"
            | "log2"
            | "min"
            | "max"
            | "pow"
    )
}

fn call_function(name: &str, args: &[f64]) -> Result<f64, String> {
    let expected = if matches!(name, "min" | "max" | "pow") { 2 } else { 1 };
    if args.len() != expected {
        return Err(format!(
            "'{}' expects {} argument{}, got {}.",
            name,
            expected,
            if expected == 1 { "" } else { "s" },
            args.len()
        ));
    }

    let value = match name {
        "sqrt" if args[0] < 0.0 => {
            return Err("cannot take the square root of a negative number.".to_string());
        }
        "ln" | "log" | "log10" | "log2" if args[0] <= 0.0 => {
            return Err("cannot take the logarithm of a number that is zero or negative."
                .to_string());
        }
        "sqrt" => args[0].sqrt(),
        "cbrt" => args[0].cbrt(),
        "abs" => args[0].abs(),
        "round" => args[0].round(),
        "floor" => args[0].floor(),
        "ceil" => args[0].ceil(),
        "trunc" => args[0].trunc(),
        "sign" => args[0].signum(),
        "exp" => args[0].exp(),
        "ln" => args[0].ln(),
        "log" | "log10" => args[0].log10(),
        "log2" => args[0].log2(),
        "min" => args[0].min(args[1]),
        "max" => args[0].max(args[1]),
        "pow" => args[0].powf(args[1]),
        _ => unreachable!("checked against is_known_function"),
    };

    Ok(value)
}

#[cfg(test)]
mod tests {
    use super::*;

    fn calc(expression: &str) -> Result<f64, String> {
        evaluate(expression)
    }

    #[test]
    fn basic_arithmetic() {
        assert_eq!(calc("1 + 2"), Ok(3.0));
        assert_eq!(calc("5 - 8"), Ok(-3.0));
        assert_eq!(calc("6 * 7"), Ok(42.0));
        assert_eq!(calc("10 / 4"), Ok(2.5));
        assert_eq!(calc("10 % 4"), Ok(2.0));
    }

    #[test]
    fn precedence_and_grouping() {
        assert_eq!(calc("2 + 3 * 4"), Ok(14.0));
        assert_eq!(calc("(2 + 3) * 4"), Ok(20.0));
        assert_eq!(calc("2 ^ 3 ^ 2"), Ok(512.0));
        assert_eq!(calc("-2 ^ 2"), Ok(-4.0));
        assert_eq!(calc("2 ^ -3"), Ok(0.125));
        assert_eq!(calc("3 * -2"), Ok(-6.0));
    }

    #[test]
    fn numbers() {
        assert_eq!(calc("0.1 + 0.2"), Ok(0.30000000000000004));
        assert_eq!(calc("1e3"), Ok(1000.0));
        assert_eq!(calc("1.5e-3"), Ok(0.0015));
        assert_eq!(calc(".5 * 2"), Ok(1.0));
    }

    #[test]
    fn functions_and_constants() {
        assert_eq!(calc("sqrt(9)"), Ok(3.0));
        assert_eq!(calc("2 * pi"), Ok(2.0 * PI));
        assert_eq!(calc("max(3, 7)"), Ok(7.0));
        assert_eq!(calc("pow(2, 10)"), Ok(1024.0));
        assert_eq!(calc("abs(-4) + round(1.6)"), Ok(6.0));
        assert_eq!(calc("log(1000)"), Ok(3.0));
    }

    #[test]
    fn unicode_operators() {
        assert_eq!(calc("2 × 3"), Ok(6.0));
        assert_eq!(calc("9 ÷ 3"), Ok(3.0));
        assert_eq!(calc("(2 + 3）"), Ok(5.0));
    }

    #[test]
    fn errors() {
        assert!(calc("").is_err());
        assert!(calc("1 / 0").is_err());
        assert!(calc("sqrt(-1)").is_err());
        assert!(calc("(1 + 2").is_err());
        assert!(calc("1 + * 2").is_err());
        assert!(calc("banana").is_err());
        assert!(calc("foo(2)").is_err());
        assert!(calc("sqrt(1, 2)").is_err());
        assert!(calc("2 3").is_err());
    }

    #[test]
    fn number_formatting() {
        assert_eq!(format_number(42.0), "42");
        assert_eq!(format_number(-0.0), "0");
        assert_eq!(format_number(0.1 + 0.2), "0.3");
        assert_eq!(format_number(10.0 / 4.0), "2.5");
        assert_eq!(format_number(100.0 / 3.0), "33.3333333333");
        assert_eq!(format_number(1e-20), "0.00000000000000000001");
        assert_eq!(format_number(f64::INFINITY), "Infinity");
    }
}
