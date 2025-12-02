import Config

# Force building Rustler NIFs from source in development
if Mix.env() == :dev do
  config :rustler_precompiled,
    force_build: [neo4j_nif: true]
end
