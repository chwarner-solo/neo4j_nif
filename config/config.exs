import Config

# Force building Rustler NIFs from source in development and test
if Mix.env() in [:dev, :test] do
  config :rustler_precompiled,
    force_build: [neo4j_nif: true]
end
