defmodule Revolver.Mixfile do
  use Mix.Project

  @version "0.1.0"

  def project do
    [app: :revolver,
     name: "Revolver",
     version: @version,
     elixir: "~> 1.3",
     elixirc_paths: elixirc_paths(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     description: description(),
     package: package()]
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
    [{:plug, "~> 1.3"},
     {:hackney, "~> 1.6", only: :test, optional: true},

     # Test dependencies
     {:bypass, "~> 0.6", only: :test},
     {:poison, "~> 3.0", only: :test},

     # Documentation dependencies
     {:ex_doc, "~> 0.14", only: :dev}]
  end

  defp description do
    "A composable HTTP Client inspired by Plug and Ecto."
  end

  defp package do
    [files: ["lib", "mix.exs", "README.md", "LICENSE"],
     maintainers: ["Sonny Scroggin"],
     licenses: ["Apache 2.0"],
     links: %{github: "https://github.com/scrogson/revolver"}]
  end
end
