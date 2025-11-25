defmodule Neo4jNifTest do
  use ExUnit.Case
  doctest Neo4jNif

  @moduletag :integration

  # Connection details for docker-compose Neo4j
  @uri "bolt://localhost:7687"
  @user "neo4j"
  @password "testpassword"

  describe "connect/3" do
    test "successfully connects to Neo4j" do
      assert {:ok, _conn} = Neo4jNif.connect(@uri, @user, @password)
    end

    test "returns error with invalid credentials" do
      {:ok, conn} = Neo4jNif.connect(@uri, "wrong", "credentials")
      assert {:error, _reason} = Neo4jNif.execute_query(conn, "RETURN 1")
    end

    test "returns error with invalid URI" do
      {:ok, conn} = Neo4jNif.connect("bolt://localhost:9999", @user, @password)
      assert {:error, _reason} = Neo4jNif.execute_query(conn, "RETURN 1")
    end
  end

  describe "execute_query/2" do
    setup do
      {:ok, conn} = Neo4jNif.connect(@uri, @user, @password)
      {:ok, conn: conn}
    end

    test "executes simple query", %{conn: conn} do
      assert {:ok, [%{"num" => 1}]} = Neo4jNif.execute_query(conn, "RETURN 1 as num")
    end

    test "returns error for invalid query", %{conn: conn} do
      assert {:error, _reason} = Neo4jNif.execute_query(conn, "INVALID CYPHER")
    end
  end

  describe "Querying Nodes" do
    setup do
      {:ok, conn} = Neo4jNif.connect(@uri, @user, @password)
      # Clean up any previous test data
      Neo4jNif.execute_query(conn, "MATCH (n:TestNode {name: 'test-node'}) DELETE n")
      # Create a test node
      Neo4jNif.execute_query(conn, "CREATE (:TestNode {name: 'test-node', value: 123})")
      {:ok, conn: conn}
    end

    test "retrieves a node and converts it to a map", %{conn: conn} do
      query = "MATCH (n:TestNode {name: 'test-node'}) RETURN n"
      {:ok, [result]} = Neo4jNif.execute_query(conn, query)

      assert %{"n" => node} = result
      assert "node" == node["__type"]
      assert ["TestNode"] == node["labels"]
      assert %{"name" => "test-node", "value" => 123} == node["properties"]
    end
  end
end
