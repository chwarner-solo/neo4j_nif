defmodule Neo4jNif.MixProject do
  use Mix.Project

  @version "0.1.0"
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
      homepage_url: @source_url,
      compilers: Mix.compilers() ++ [:rustler_precompiled],
      rustler_precompiled: [
        app: :neo4j_nif,
        crate: "neo4j_nif",
        base_url: "#{@source_url}/releases/download/v#{@version}",
        version: @version
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger, :rustler]
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.2"},
      {:rustler, "~> 0.37.0"},
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
