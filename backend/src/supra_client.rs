use reqwest::Client;
use serde_json::{json, Value};

pub async fn fetch_prices() -> Result<Value, Box<dyn std::error::Error>> {
    let client = Client::new();

    // Replace this with the correct oracle price function when available
    let payload = json!({
        "function": "0x1::timestamp::now_microseconds", // TEMP placeholder
        "type_arguments": [],
        "arguments": []
    });

    let response = client
        .post("https://rpc-testnet.supra.com/rpc/v1/view")
        .json(&payload)
        .send()
        .await?;

    if !response.status().is_success() {
        return Err(format!("RPC error: {}", response.status()).into());
    }

    let raw = response.text().await?;
    let json: Value = serde_json::from_str(&raw)?;

    // If oracle returns result array, extract it cleanly
    let result = json.get("result").cloned().unwrap_or(Value::Null);
    Ok(result)
}

