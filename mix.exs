defmodule Neo4jNif.MixProject do
  use Mix.Project

  @version "0.1.0-dev"
  @source_url "https://github.com/chwarner-solo/neo4j_nif"

  def project do
    [
      app: :neo4j_nif,
      version: @version,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: description(),
      docs: docs(),
      name: "Neo4j NIF",
      source_url: @source_url,
      homepage_url: @source_url
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:rustler, "~> 0.37.0", runtime: false},
      {:rustler_precompiled, "~> 0.8"},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end

  defp description do
    """
    High-performance Neo4j driver for Elixir using Rust NIFs.
    Provides native speed and comprehensive Neo4j type support including
    spatial, temporal, and graph types. Built on neo4rs with full Neo4j Aura support.
    """
  end

  defp package do
    [
      name: "neo4j_nif",
      files: [
        "lib",
        "native/neo4j_nif/src",
        "native/neo4j_nif/Cargo.toml",
        "native/neo4j_nif/Cargo.lock",
        "checksum-*.exs",
        "mix.exs",
        "README.md",
        "LICENSE",
        "CHANGELOG.md"
      ],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Changelog" => "#{@source_url}/blob/main/CHANGELOG.md"
      },
      maintainers: ["Chris Warner"]
    ]
  end

  defp docs do
    [
      main: "Neo4jNif",
      extras: ["README.md", "CHANGELOG.md"],
      source_ref: "v#{@version}",
      source_url: @source_url
    ]
  end
end
