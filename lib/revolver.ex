defmodule Revolver do
  @moduledoc """
  An Elixir HTTP Client with support for HTTP/1.1, SPDY, and WebSocket.
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    register_default_ports()

    children = []

    opts = [strategy: :one_for_one, name: Revolver.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp register_default_ports do
    Enum.each(default_ports(), fn {scheme, port} ->
      case URI.default_port(scheme) do
        nil -> URI.default_port(scheme, port)
        _   -> :ok
      end
    end)
  end

  defp default_ports do
    Application.get_env(:revolver, :default_ports)
  end
end
