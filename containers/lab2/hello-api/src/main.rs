use axum::{routing::get, Router};
use tokio::net::TcpListener;

#[tokio::main]
async fn main() {
    let app = Router::new().route("/", get(|| async { "Hello from Rust!" }));

    let listener = TcpListener::bind("0.0.0.0:").await.unwrap();
    axum::serve(listener, app).await.unwrap();
}