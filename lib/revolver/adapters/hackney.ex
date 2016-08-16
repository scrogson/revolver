defmodule Revolver.Adapters.Hackney do
  import Revolver.Conn

  def conn(config, opts \\ []) do
    %URI{scheme: scheme, host: host, port: port} = URI.parse(config[:endpoint])
    req_headers = config[:headers] || []
    req_path = config[:req_path]

    {:ok, state} = :hackney.connect(transport(scheme), host, port, opts)

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

  def send_req(%Revolver.Conn{adapter: {mod, state}} = conn, opts \\ []) do
    req_data = {conn.method, req_path(conn), conn.req_headers, conn.req_body}
    {:ok, status, resp_headers, state} = :hackney.send_request(state, req_data)
    {:ok, body} = :hackney.body(state)
    {:ok, %{conn | adapter: {mod, state},
                   resp_body: body,
                   resp_headers: normalize_headers(resp_headers),
                   status: status}}
  end

  defp req_path(%Revolver.Conn{query_params: query} = conn) when query == %{},
    do: conn.req_path
  defp req_path(%Revolver.Conn{req_path: path, query_params: query}),
    do: URI.to_string(%URI{path: path, query: Plug.Conn.Query.encode(query)})

  defp normalize_headers(headers),
    do: normalize_headers(headers, [])
  defp normalize_headers([], acc),
    do: acc
  defp normalize_headers([{k, v}|t], acc),
    do: normalize_headers(t, [{String.downcase(k), v} | acc])

  defp transport("http"), do: :hackney_tcp_transport
  defp transport("https"), do: :hackney_ssl_transport
end
