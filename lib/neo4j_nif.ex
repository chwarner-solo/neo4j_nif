defmodule Neo4jNif do
  @moduledoc """
  High-performance Neo4j driver for Elixir using Rust NIFs.

  Neo4jNif provides a native interface to Neo4j with comprehensive type support
  including spatial, temporal, and graph types. Built on the `neo4rs` Rust library
  with full support for Neo4j Aura.

  ## Example

      # Connect to Neo4j
      {:ok, conn} = Neo4jNif.connect(
        "neo4j+s://xxx.databases.neo4j.io",
        "neo4j",
        "password"
      )

      # Execute a query
      {:ok, results} = Neo4jNif.execute_query(
        conn,
        "MATCH (n:Person) RETURN n LIMIT 5"
      )

  ## Current Status

  This library is under active development. The Row API implementation is incomplete,
  so query results currently return empty maps. See the README for current status
  and roadmap.
  """

  use Rustler,
    otp_app: :neo4j_nif,
    crate: "neo4j_nif"

  @doc """
  Connect to a Neo4j database.

  Returns `{:ok, connection}` on success or `{:error, reason}` on failure.

  ## Parameters

    * `uri` - Neo4j connection URI (e.g., "neo4j+s://xxx.databases.neo4j.io" for Aura)
    * `user` - Database username
    * `password` - Database password

  ## Examples

      iex> Neo4jNif.connect("bolt://localhost:7687", "neo4j", "password")
      {:ok, #Reference<...>}

      iex> Neo4jNif.connect("neo4j+s://xxx.databases.neo4j.io", "neo4j", "password")
      {:ok, #Reference<...>}

      iex> Neo4jNif.connect("bolt://localhost:9999", "wrong", "credentials")
      {:error, "Connection failed: ..."}
  """
  @spec connect(uri :: String.t(), user :: String.t(), password :: String.t()) ::
          {:ok, reference()} | {:error, String.t()}
  def connect(_uri, _user, _password), do: :erlang.nif_error(:nif_not_loaded)

  @doc """
  Execute a Cypher query against the database.

  Returns `{:ok, results}` where results is a list of maps, or `{:error, reason}` on failure.

  ## Parameters

    * `connection` - Connection reference from `connect/3`
    * `query` - Cypher query string

  ## Examples

      iex> {:ok, conn} = Neo4jNif.connect("bolt://localhost:7687", "neo4j", "password")
      iex> Neo4jNif.execute_query(conn, "MATCH (n:Person) RETURN n.name as name LIMIT 5")
      {:ok, [%{"name" => "Alice"}, %{"name" => "Bob"}]}

      iex> Neo4jNif.execute_query(conn, "INVALID QUERY")
      {:error, "Query execution failed: ..."}

  ## Result Format

  Results are returned as a list of maps. Each map represents one row of results.

  Graph types include a `__type` field for identification:

      # Node
      %{
        "__type" => "node",
        "id" => 123,
        "labels" => ["Person", "Employee"],
        "properties" => %{"name" => "Alice", "age" => 30}
      }

      # Relationship
      %{
        "__type" => "relationship",
        "id" => 456,
        "start_node_id" => 123,
        "end_node_id" => 789,
        "type" => "KNOWS",
        "properties" => %{"since" => 2020}
      }

      # Path
      %{
        "__type" => "path",
        "nodes" => [node1, node2, node3],
        "relationships" => [rel1, rel2],
        "indices" => [1, 1]
      }

  ## Current Limitation

  ⚠️ Due to incomplete Row API implementation, this currently returns empty result sets.
  This is being actively worked on.
  """
  @spec execute_query(connection :: reference(), query :: String.t()) ::
          {:ok, [map()]} | {:error, String.t()}
  def execute_query(_connection, _query), do: :erlang.nif_error(:nif_not_loaded)
end
