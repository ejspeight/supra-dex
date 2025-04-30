use axum::{Router, serve};
use std::net::SocketAddr;
use tokio::net::TcpListener;
use tracing_subscriber;

mod routes;
mod supra_client;

#[tokio::main]
async fn main() {
    tracing_subscriber::fmt::init();

    let app = Router::new().nest("/api", routes::oracle_routes());

    let addr = SocketAddr::from(([127, 0, 0, 1], 3000));
    let listener = TcpListener::bind(addr).await.unwrap();

    println!("Server listening on http://{}", addr);

    serve(listener, app.into_make_service())
        .await
        .unwrap();
}