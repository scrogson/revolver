defmodule Revolver.Mixfile do
  use Mix.Project

  @version "0.1.0"

  def project do
    [app: :revolver,
     version: @version,
     elixir: "~> 1.3",
     elixirc_paths: elixirc_paths(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [mod: {Revolver, []},
     env: [default_ports: [{"ws", 80}, {"wss", 443}],
           serializers: %{"application/json" => Poison}],
     applications: [:logger, :plug]]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [{:plug, "~> 1.2-rc", override: true},
     {:hackney, "~> 1.6", only: :test, optional: true},

     # Test dependencies
     {:bypass, "~> 0.5", only: :test},
     {:poison, "~> 2.0", only: :test},

     # Documentation dependencies
     {:ex_doc, ">= 0.0.0", only: :dev},
     {:earmark, ">= 0.0.0", only: :dev}]
  end
end
