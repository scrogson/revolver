defmodule Revolver.Mixfile do
  use Mix.Project

  def project do
    [app: :revolver,
     version: "0.1.0",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:crypto, :gun]]
  end

  defp deps do
    [{:gun, github: "ninenines/gun"}]
  end
end
