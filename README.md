Revolver
========

An Elixir HTTP Client with support for HTTP and WebSocket.

> **WARNING:** This library is not ready for use, so don't use it yet.

The library is an experiment. The goal is to create something that is very
composeable, like [Plug]. It will provide adapters for different Erlang
HTTP clients. The first adapter will be for [Gun].

## Desired API (?)

```elixir
conn = Revolver.connect(host: "https://api.github.com"), fn conn ->
  conn
  |> put_adapter(Revolver.Adapters.Gun)
  |> put_req_header("accept", "application/json")
  |> register_after_resp(fn conn ->
    %{conn | resp_body: Poison.decode!(conn.resp_body)}
  end)
end

IO.inspect conn
#=> %Revolver.Conn{host: "google.com", port: 443, scheme: :https, ...}

conn = conn |> Revolver.get("/")

conn.resp_body
#=> {"current_user_url":"https://api.github.com/user","current_user_authorizations_html_url":"https://github.com/settings/connections/applications{/client_id}","authorizations_url":"https://api.github.com/authorizations", ...}

```

[Plug]: https://github.com/elixir-lang/plug
[Gun]: https://github.com/ninenines/gun
