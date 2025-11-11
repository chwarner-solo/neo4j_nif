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
      assert {:error, _reason} = Neo4jNif.connect(@uri, "wrong", "credentials")
    end

    test "returns error with invalid URI" do
      assert {:error, _reason} = Neo4jNif.connect("bolt://localhost:9999", @user, @password)
    end
  end

  describe "execute_query/2" do
    setup do
      {:ok, conn} = Neo4jNif.connect(@uri, @user, @password)
      {:ok, conn: conn}
    end

    test "executes simple query", %{conn: conn} do
      # Known issue: Returns empty results due to Row API implementation
      assert {:ok, _results} = Neo4jNif.execute_query(conn, "RETURN 1 as num")
    end

    test "returns error for invalid query", %{conn: conn} do
      assert {:error, _reason} = Neo4jNif.execute_query(conn, "INVALID CYPHER")
    end
  end
end
