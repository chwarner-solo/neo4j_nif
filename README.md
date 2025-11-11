# Neo4j NIF

**Native Elixir driver for Neo4j using Rust NIFs**

> ⚠️ **Early Development**: This library is under active development. The Row API implementation is incomplete. See [Current Status](#current-status) for details.

A high-performance Neo4j driver for Elixir built on Rust NIFs, providing native speed and comprehensive Neo4j type support.

## Why Neo4j NIF?

### The Problem with Existing Drivers

**bolt_sips** (Pure Elixir):
- Limited Neo4j Aura support
- Performance overhead from pure Elixir implementation
- Incomplete spatial and temporal type support

**neo4j** (Official, unmaintained):
- No longer maintained
- Doesn't support modern Bolt protocols
- Incompatible with Neo4j 5.x

### Neo4j NIF Solution

- ✅ **Native Performance**: Rust NIF for zero-copy data transfer
- ✅ **Neo4j Aura Support**: Full `bolt+s://` protocol support
- ✅ **Comprehensive Types**: Spatial, temporal, and graph types
- ✅ **Modern Protocol**: Bolt 5.x support via `neo4rs`
- ✅ **Production-Ready Runtime**: Tokio-based async runtime
- 🚧 **Active Development**: Rapidly evolving with community input

## Installation

Add `neo4j_nif` to your `mix.exs` dependencies:

```elixir
def deps do
  [
    {:neo4j_nif, "~> 0.1.0-dev"}
  ]
end
```

**Note**: Precompiled NIFs are provided for common platforms. You don't need Rust installed unless you're on an unsupported platform.

## Usage

```elixir
# Connect to Neo4j
{:ok, conn} = Neo4jNif.connect(
  "neo4j+s://xxx.databases.neo4j.io",
  "neo4j",
  "your_password"
)

# Execute a query
{:ok, results} = Neo4jNif.execute_query(
  conn,
  "MATCH (n:Person) WHERE n.name = 'Alice' RETURN n"
)

# Results are maps with __type markers for graph types
# %{
#   "n" => %{
#     "__type" => "node",
#     "id" => 123,
#     "labels" => ["Person"],
#     "properties" => %{"name" => "Alice", "age" => 30}
#   }
# }
```

## Supported Types

Neo4j NIF handles all Neo4j types:

**Primitive Types**:
- `Null` → `:nil`
- `Boolean` → `true`/`false`
- `Integer` → `integer()`
- `Float` → `float()`
- `String` → `String.t()`
- `Bytes` → `String.t()` (debug representation)

**Collection Types**:
- `List` → `list()`
- `Map` → `map()`

**Graph Types** (with `__type` marker):
- `Node` → `%{__type: "node", id: integer(), labels: [String.t()], properties: map()}`
- `Relationship` → `%{__type: "relationship", id: integer(), start_node_id: integer(), end_node_id: integer(), type: String.t(), properties: map()}`
- `Path` → `%{__type: "path", nodes: [node()], relationships: [relationship()], indices: [integer()]}`

**Spatial Types**:
- `Point2D` → `%{__type: "point2d", srid: integer(), x: float(), y: float()}`
- `Point3D` → `%{__type: "point3d", srid: integer(), x: float(), y: float(), z: float()}`

**Temporal Types** (currently as debug strings):
- `Date`, `Time`, `DateTime`, `LocalTime`, `LocalDateTime`, `Duration`

## Current Status

### Working
- ✅ Connection to Neo4j (including Aura with `bolt+s://`)
- ✅ Query execution
- ✅ Comprehensive type conversion (primitives, collections, graph types, spatial)
- ✅ Resource management (connection lifetime)
- ✅ Error handling

### In Progress
- 🚧 **Row API Implementation**: Currently returns empty results due to incomplete `neo4rs` 0.8 Row API integration
- 🚧 Full test coverage
- 🚧 Connection pooling
- 🚧 Transaction support

### Planned
- 📋 Better temporal type representation (Elixir structs vs debug strings)
- 📋 Streaming results for large queries
- 📋 Parameterized queries
- 📋 Batch operations
- 📋 Comprehensive documentation and examples

## Development

### Prerequisites

- Elixir 1.15+
- Rust 1.70+ (for building from source)
- Docker (for running Neo4j during tests)

### Setup

```bash
# Clone the repository
git clone https://github.com/chwarner-solo/neo4j_nif.git
cd neo4j_nif

# Install dependencies
mix deps.get

# Start Neo4j for testing
docker-compose up -d

# Run tests
mix test
```

### Testing Against Neo4j

A `docker-compose.yml` is provided for local development:

```bash
# Start Neo4j
docker-compose up -d

# Neo4j will be available at:
# - Bolt: bolt://localhost:7687
# - Browser: http://localhost:7474
# - Credentials: neo4j/testpassword

# Run tests
mix test

# Stop Neo4j
docker-compose down
```

## Architecture

**Rust NIF Layer** (`native/neo4j_nif/`):
- Uses `neo4rs` for Neo4j Bolt protocol
- Tokio runtime for async operations
- Comprehensive type conversion to Elixir terms
- Resource-based connection management

**Elixir API** (`lib/neo4j_nif.ex`):
- Thin wrapper over NIF functions
- Idiomatic Elixir error handling
- Result-tuple returns (`:ok`/`:error`)

## Contributing

Contributions are welcome! This is an early-stage project with lots of opportunity to improve.

**Priority areas**:
1. **Fix Row API**: Help figure out proper `neo4rs` 0.8 Row column access
2. **Test coverage**: Add comprehensive tests
3. **Documentation**: Improve examples and guides
4. **Type refinements**: Better temporal type handling

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Why I'm Building This

I'm building Grimoire, a prompt engineering tool for game writers that uses Neo4j for story graph management. The existing Elixir Neo4j drivers didn't meet my needs:
- `bolt_sips` had issues with Neo4j Aura
- The official driver is unmaintained
- I needed native performance for graph traversals

Rather than work around these limitations, I'm building the driver the Elixir ecosystem needs.

**Building in public**: Follow the journey on [LinkedIn](https://www.linkedin.com/in/chris-warner-9960ab7) and [my blog](#).

## License

MIT License - see [LICENSE](LICENSE) for details.

## Author

**Chris Warner**
- 28 years building distributed systems
- Three active GCP certifications
- Currently building AI-powered narrative tools for game writers

---

**This is early development software. Use in production at your own risk. Contributions and feedback welcome!**
