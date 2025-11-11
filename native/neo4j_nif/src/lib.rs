mod atoms;
mod conversions;

use rustler::{Env, ResourceArc, Term, Encoder};
use neo4rs::{Graph, query};
use tokio::runtime::Runtime;
use std::sync::Arc;

use conversions::convert_row_to_elixir;

/// Resource holding the Neo4j graph connection and its runtime
pub struct GraphResource {
    pub graph: Arc<Graph>,
    pub runtime: Arc<Runtime>,
}

/// Register the resource type with Rustler
#[allow(non_local_definitions)]
fn on_load(env: Env, _info: Term) -> bool {
    rustler::resource!(GraphResource, env);
    true
}

/// Connect to Neo4j and create a persistent runtime
///
/// Returns `{:ok, resource}` or `{:error, reason}`
#[rustler::nif(schedule = "DirtyCpu")]
fn connect<'a>(env: Env<'a>, uri: String, user: String, pass: String) -> Term<'a> {
    let runtime = match Runtime::new() {
        Ok(rt) => rt,
        Err(e) => {
            let error_msg = format!("Failed to create runtime: {}", e);
            return (atoms::error(), error_msg).encode(env);
        }
    };

    let graph = match runtime.block_on(async {
        Graph::new(&uri, &user, &pass).await
    }) {
        Ok(g) => g,
        Err(e) => {
            let error_msg = format!("Connection failed: {}", e);
            return (atoms::error(), error_msg).encode(env);
        }
    };

    let resource = GraphResource {
        graph: Arc::new(graph),
        runtime: Arc::new(runtime),
    };

    (atoms::ok(), ResourceArc::new(resource)).encode(env)
}

/// Execute a Cypher query and return results as list of maps
///
/// Returns `{:ok, [%{column => value}, ...]}` or `{:error, reason}`
#[rustler::nif(schedule = "DirtyCpu")]
fn execute_query<'a>(
    env: Env<'a>,
    resource: ResourceArc<GraphResource>,
    query_str: String,
) -> Term<'a> {
    let results = resource.runtime.block_on(async {
        let mut result = match resource.graph.execute(query(&query_str)).await {
            Ok(r) => r,
            Err(e) => return Err(format!("Query execution failed: {}", e)),
        };

        let mut records = Vec::new();

        loop {
            match result.next().await {
                Ok(Some(row)) => {
                    match convert_row_to_elixir(&row) {
                        Ok(elixir_row) => records.push(elixir_row),
                        Err(e) => return Err(e),
                    }
                },
                Ok(None) => break,
                Err(e) => return Err(format!("Row fetch failed: {}", e)),
            }
        }

        Ok(records)
    });

    match results {
        Ok(rows) => (atoms::ok(), rows).encode(env),
        Err(msg) => (atoms::error(), msg).encode(env),
    }
}

rustler::init!(
    "Elixir.Neo4jNif",
    load = on_load
);
