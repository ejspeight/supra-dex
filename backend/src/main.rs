use reqwest::Client;
use serde_json::{json, Value};

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let client = Client::new();

    // add smart contract/module function to payload
    let payload = json!({
        "function": "0x1::timestamp::now_microseconds",
        "type_arguments": [],
        "arguments": [] 
    });

    let response = client
        .post("https://rpc-testnet.supra.com/rpc/v1/view")
        .json(&payload)
        .send()
        .await?;

    if !response.status().is_success() {
        eprintln!("Error: receieved non 200 status: {}", response.status());
        return Ok(());
    }


   println!("Status: {}", response.status());
   println!("Headers:\n{:#?}", response.headers());
   

    let raw = response.text().await?;
    print!("Raw body:\n{}", raw);

    let json: Value = serde_json::from_str(&raw)?;

    if let Some(result) = json["result"].get(0) {
        println!("Parsed result: {}", result);
    } else {
        println!("No result returned from function.");
    }

    Ok(())
}

