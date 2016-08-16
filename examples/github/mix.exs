defmodule GitHub.Mixfile do
  use Mix.Project

  def project do
    [app: :github,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:logger, :revolver, :hackney, :poison]]
  end

  defp deps do
    [{:revolver, path: "../.."},
     {:hackney, "~> 1.6"},
     {:poison, "~> 2.2"}]
  end
end
