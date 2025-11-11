use rustler::{Env, Term, Encoder};
use neo4rs::{Row, BoltType};
use std::collections::HashMap;

use crate::atoms;

/// Convert a Neo4j Row to an Elixir-friendly map
///
/// NOTE: neo4rs 0.8 Row doesn't expose column names easily
/// For now, returning debug representation
/// TODO: Figure out proper neo4rs 0.8 Row API
pub fn convert_row_to_elixir(_row: &Row) -> Result<HashMap<String, ElixirValue>, String> {
    let row_map = HashMap::new();

    // Temporary: Return empty map until we figure out Row API
    // The query results will be empty for now

    Ok(row_map)
}

/// Wrapper type for encoding Neo4j BoltType values as Elixir terms
#[derive(Debug, Clone)]
pub enum ElixirValue {
    Null,
    Boolean(bool),
    Integer(i64),
    Float(f64),
    String(String),
    List(Vec<ElixirValue>),
    Map(HashMap<String, ElixirValue>),
}

impl ElixirValue {
    /// Convert a Neo4j BoltType to ElixirValue
    pub fn from_bolt(bolt: BoltType) -> Self {
        match bolt {
            BoltType::Null(_) => Self::Null,
            BoltType::Boolean(b) => Self::Boolean(b.value),
            BoltType::Integer(i) => Self::Integer(i.value),
            BoltType::Float(f) => Self::Float(f.value),
            BoltType::String(s) => Self::String(s.value),
            BoltType::Bytes(b) => Self::String(format!("{:?}", b.value)),

            BoltType::List(list) => {
                let items = list.value
                    .into_iter()
                    .map(Self::from_bolt)
                    .collect();
                Self::List(items)
            },

            BoltType::Map(map) => {
                let items = map.value
                    .into_iter()
                    .map(|(k, v)| (k.value, Self::from_bolt(v)))
                    .collect();
                Self::Map(items)
            },

            // Neo4j graph types - convert to maps with __type field
            BoltType::Node(node) => convert_node_to_map(node),
            BoltType::Relation(rel) => convert_relation_to_map(rel),
            BoltType::UnboundedRelation(rel) => convert_unbounded_relation_to_map(rel),
            BoltType::Path(path) => convert_path_to_map(path),

            // Spatial types
            BoltType::Point2D(p) => convert_point2d_to_map(p),
            BoltType::Point3D(p) => convert_point3d_to_map(p),

            // Temporal types - convert to strings for now
            BoltType::Date(d) => Self::String(format!("{:?}", d)),
            BoltType::Time(t) => Self::String(format!("{:?}", t)),
            BoltType::DateTime(dt) => Self::String(format!("{:?}", dt)),
            BoltType::DateTimeZoneId(dt) => Self::String(format!("{:?}", dt)),
            BoltType::LocalTime(lt) => Self::String(format!("{:?}", lt)),
            BoltType::LocalDateTime(ldt) => Self::String(format!("{:?}", ldt)),
            BoltType::Duration(dur) => Self::String(format!("{:?}", dur)),
        }
    }
}

/// Implement Encoder to convert ElixirValue to Elixir terms
impl Encoder for ElixirValue {
    fn encode<'a>(&self, env: Env<'a>) -> Term<'a> {
        match self {
            Self::Null => atoms::nil().encode(env),
            Self::Boolean(b) => b.encode(env),
            Self::Integer(i) => i.encode(env),
            Self::Float(f) => f.encode(env),
            Self::String(s) => s.encode(env),
            Self::List(items) => items.encode(env),
            Self::Map(map) => map.encode(env),
        }
    }
}

// Helper functions for converting Neo4j graph types

fn convert_node_to_map(node: neo4rs::BoltNode) -> ElixirValue {
    let mut map = HashMap::new();

    map.insert("__type".to_string(), ElixirValue::String("node".to_string()));
    map.insert("id".to_string(), ElixirValue::Integer(node.id.value));

    // Convert labels - BoltList contains BoltType::String variants
    let labels: Vec<ElixirValue> = node.labels.value
        .into_iter()
        .map(|bolt_type| {
            if let BoltType::String(s) = bolt_type {
                ElixirValue::String(s.value)
            } else {
                ElixirValue::String(format!("{:?}", bolt_type))
            }
        })
        .collect();
    map.insert("labels".to_string(), ElixirValue::List(labels));

    map.insert("properties".to_string(), ElixirValue::from_bolt(BoltType::Map(node.properties)));

    ElixirValue::Map(map)
}

fn convert_relation_to_map(rel: neo4rs::BoltRelation) -> ElixirValue {
    let mut map = HashMap::new();

    map.insert("__type".to_string(), ElixirValue::String("relationship".to_string()));
    map.insert("id".to_string(), ElixirValue::Integer(rel.id.value));
    map.insert("start_node_id".to_string(), ElixirValue::Integer(rel.start_node_id.value));
    map.insert("end_node_id".to_string(), ElixirValue::Integer(rel.end_node_id.value));
    map.insert("type".to_string(), ElixirValue::String(rel.typ.value));
    map.insert("properties".to_string(), ElixirValue::from_bolt(BoltType::Map(rel.properties)));

    ElixirValue::Map(map)
}

fn convert_unbounded_relation_to_map(rel: neo4rs::BoltUnboundedRelation) -> ElixirValue {
    let mut map = HashMap::new();

    map.insert("__type".to_string(), ElixirValue::String("unbounded_relationship".to_string()));
    map.insert("id".to_string(), ElixirValue::Integer(rel.id.value));
    map.insert("type".to_string(), ElixirValue::String(rel.typ.value));
    map.insert("properties".to_string(), ElixirValue::from_bolt(BoltType::Map(rel.properties)));

    ElixirValue::Map(map)
}

fn convert_path_to_map(path: neo4rs::BoltPath) -> ElixirValue {
    let mut map = HashMap::new();

    map.insert("__type".to_string(), ElixirValue::String("path".to_string()));

    let nodes: Vec<ElixirValue> = path.nodes
        .into_iter()
        .map(|bolt_type| {
            if let BoltType::Node(node) = bolt_type {
                convert_node_to_map(node)
            } else {
                ElixirValue::String(format!("{:?}", bolt_type))
            }
        })
        .collect();
    map.insert("nodes".to_string(), ElixirValue::List(nodes));

    let rels: Vec<ElixirValue> = path.rels
        .into_iter()
        .map(|bolt_type| {
            if let BoltType::UnboundedRelation(rel) = bolt_type {
                convert_unbounded_relation_to_map(rel)
            } else {
                ElixirValue::String(format!("{:?}", bolt_type))
            }
        })
        .collect();
    map.insert("relationships".to_string(), ElixirValue::List(rels));

    let indices: Vec<ElixirValue> = path.indices
        .into_iter()
        .map(|bolt_type| {
            if let BoltType::Integer(i) = bolt_type {
                ElixirValue::Integer(i.value)
            } else {
                ElixirValue::Integer(0)
            }
        })
        .collect();
    map.insert("indices".to_string(), ElixirValue::List(indices));

    ElixirValue::Map(map)
}

fn convert_point2d_to_map(point: neo4rs::BoltPoint2D) -> ElixirValue {
    let mut map = HashMap::new();

    map.insert("__type".to_string(), ElixirValue::String("point2d".to_string()));
    map.insert("srid".to_string(), ElixirValue::Integer(point.sr_id.value as i64));
    map.insert("x".to_string(), ElixirValue::Float(point.x.value));
    map.insert("y".to_string(), ElixirValue::Float(point.y.value));

    ElixirValue::Map(map)
}

fn convert_point3d_to_map(point: neo4rs::BoltPoint3D) -> ElixirValue {
    let mut map = HashMap::new();

    map.insert("__type".to_string(), ElixirValue::String("point3d".to_string()));
    map.insert("srid".to_string(), ElixirValue::Integer(point.sr_id.value as i64));
    map.insert("x".to_string(), ElixirValue::Float(point.x.value));
    map.insert("y".to_string(), ElixirValue::Float(point.y.value));
    map.insert("z".to_string(), ElixirValue::Float(point.z.value));

    ElixirValue::Map(map)
}
