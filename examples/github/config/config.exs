use Mix.Config

config :revolver,
  serializers: %{
    "application/json" => Poison,
    "application/vnd.github.v3+json" => Poison
  }

config :github, GitHub,
  adapter: Revolver.Adapters.Hackney,
  endpoint: "https://api.github.com",
  headers: [
    {"accept", "application/vnd.github.v3+json"},
    {"content-type", "application/json"}
  ]
