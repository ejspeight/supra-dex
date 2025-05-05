use axum::{routing::get, Router};
use axum::response::Json;
use serde_json::{json, Value};
use crate::supra_client::{fetch_prices, get_pools};

pub fn oracle_routes() -> Router {
    Router::new()
        .route("/prices", get(prices_handler))
        .route("/pools", get(pools_handler))
}

async fn prices_handler() -> Json<Value> {
    match fetch_prices().await {
        Ok(data) => Json(json!({ "status": "ok", "data": data })),
        Err(e) => Json(json!({ "status": "error", "message": e.to_string() })),
    }
}

async fn pools_handler() -> Json<Value> {
    match get_pools().await {
        Ok(data) => Json(json!({ "status": "ok", "data": data })),
        Err(e) => Json(json!({ "status": "error", "message": e.to_string() })),
    }
}



