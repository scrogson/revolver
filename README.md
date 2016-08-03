Revolver
========

An Elixir HTTP Client inspired by [Plug].

> **WARNING:** This library is not ready for use, so don't use it yet.

The library is currently an experiment. The goal is to create something that is
very composeable, like [Plug]. It will provide adapters for different Erlang
HTTP clients.

## Desired API (?)

```elixir
defmodule GitHub.Client do
  use Revolver.Client, otp_app: :github
end

defmodule GitHub.Repos do
  use Revolver.Conn

  @doc """
  Fetches a list of repos for the give username.
  """
  def list!(user) do
    conn("/users/#{user}/repos") |> GitHub.Client.get!
  end

  @doc """
  Create a repo for the current user (based on OAuth token)
  """
  def create!(token, params \\ %{}) do
    params = Map.take(params, ~w(name description homepage private has_issues
                                 has_wiki has_downloads team_id auto_init
                                 gitignore_template license_template)a)
    conn("/user/repos")
    |> put_req_body(params)
    |> put_authorization("Bearer", token)
    |> GitHub.Client.post!
  end
end

# config/config.exs
config :github, GitHub.Client,
  adapter: Revolver.Adapters.Hackney,
  host: "api.github.com",
  scheme: :https,
  headers: [
    {"accept", "application/vnd.github.v3+json"},
    {"content-type", "application/json"}
  ]

# Configure serializers for automatic encoding/decoding request/response bodies
config :revolver,
  serializers: %{
    "application/json" => Poison,
    "application/vnd.github.v3+json" => Poison
  }

conn = GitHub.Issue.list!("scrogson")

IO.inspect conn
#=> %Revolver.Conn{host: "api.github.com", port: 443, scheme: :https, ...}

conn.resp_body
#=> [%{...}, %{...}]
```

[Plug]: https://github.com/elixir-lang/plug
