defmodule Revolver.Adapters.HackneyTest do
  use ExUnit.Case, async: true

  alias Revolver.Adapters.HackneyTest.{TestClient, User}

  describe "Hackney Adapter" do
    setup [:configure_client, :define_modules]

    test "GET request", %{server: server} do
      Bypass.expect server, fn conn ->
        assert conn.request_path == "/users"
        assert conn.method == "GET"
        assert ["application/json"] == Plug.Conn.get_req_header(conn, "accept")
        assert ["application/json"] == Plug.Conn.get_req_header(conn, "content-type")

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(200, ~s<{"data": []}>)
      end

      {:ok, conn} = User.list_users
      assert conn.resp_body == ~s<{"data": []}>
      assert ["application/json; charset=utf-8"] == Revolver.Conn.get_resp_header(conn, "content-type")
    end

    test "POST request", %{server: server} do
      Bypass.expect server, fn conn ->
        assert conn.request_path == "/users"
        assert conn.method == "POST"
        assert ["application/json"] == Plug.Conn.get_req_header(conn, "accept")
        assert ["application/json"] == Plug.Conn.get_req_header(conn, "content-type")
        assert ["Bearer abc123"] == Plug.Conn.get_req_header(conn, "authorization")

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(201, "")
      end

      {:ok, conn} = User.create_user("abc123", %{})
      assert conn.status == 201
      assert conn.resp_body == ""
      assert ["application/json; charset=utf-8"] == Revolver.Conn.get_resp_header(conn, "content-type")
    end
  end

  defp configure_client(_context) do
    Application.ensure_all_started(:hackney)

    bypass = Bypass.open

    Application.put_env(:test_app, Revolver.Adapters.HackneyTest.TestClient, [
      adapter: Revolver.Adapters.Hackney,
      endpoint: "http://localhost:#{bypass.port}",
      headers: [
        {"accept", "application/json"},
        {"content-type", "application/json"}
      ]
    ])

    {:ok, server: bypass}
  end

  defp define_modules(context) do
    defmodule TestClient do
      use Revolver.Client, otp_app: :test_app
    end

    defmodule User do
      import TestClient
      import Revolver.Conn

      def list_users do
        get conn("/users")
      end

      def create_user(token, params \\ %{}) do
        conn("/users")
        |> put_req_header("authorization", "Bearer " <> token)
        #|> put_req_body(params)
        |> post
      end
    end

    {:ok, context}
  end
end
