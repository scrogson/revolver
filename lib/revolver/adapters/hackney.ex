defmodule Revolver.Adapters.Hackney do
  import Revolver.Conn

  def conn(config) do
    %URI{scheme: scheme, host: host, port: port} = URI.parse(config[:endpoint])
    req_headers = config[:headers] || []
    req_path = config[:req_path]

    {:ok, state} = :hackney.connect(transport(scheme), host, port, [])

    %Revolver.Conn{
      adapter: {__MODULE__, state},
      host: host,
      owner: self(),
      port: port,
      req_headers: req_headers,
      req_path: req_path,
      scheme: scheme
    }
  end

  def send_req(%Revolver.Conn{adapter: {mod, state}} = conn) do
    req_data = {conn.method, conn.req_path, conn.req_headers, conn.req_body}
    {:ok, status, resp_headers, state} = :hackney.send_request(state, req_data)
    {:ok, body} = :hackney.body(state)
    {:ok, %{conn | adapter: {mod, state},
                   resp_body: body,
                   resp_headers: resp_headers,
                   status: status}}
  end

  defp transport("http"), do: :hackney_tcp_transport
  defp transport("https"), do: :hackney_ssl_transport
end
