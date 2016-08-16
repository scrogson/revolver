defmodule Revolver.ClientTest do
  use ExUnit.Case, async: true

  alias Revolver.ClientTest.{TestAdapter, TestClient, User}

  describe "TestClient" do
    setup [:configure_client, :define_modules]

    test "it exports http verb functions and base request function" do
      exports = TestClient.__info__(:exports)
      find_exports = fn key -> Enum.filter(exports, fn {k, _} -> key == k end) end

      assert [conn: 1, conn: 2] == find_exports.(:conn)

      assert [get: 1, get: 2] == find_exports.(:get)
      assert [get!: 1, get!: 2] == find_exports.(:get!)
      assert [post: 1, post: 2] == find_exports.(:post)
      assert [post!: 1, post!: 2] == find_exports.(:post!)
      assert [put: 1, put: 2] == find_exports.(:put)
      assert [put!: 1, put!: 2] == find_exports.(:put!)
      assert [patch: 1, patch: 2] == find_exports.(:patch)
      assert [patch!: 1, patch!: 2] == find_exports.(:patch!)
      assert [delete: 1, delete: 2] == find_exports.(:delete)
      assert [delete!: 1, delete!: 2] == find_exports.(:delete!)
      assert [head: 1, head: 2] == find_exports.(:head)
      assert [head!: 1, head!: 2] == find_exports.(:head!)
      assert [trace: 1, trace: 2] == find_exports.(:trace)
      assert [trace!: 1, trace!: 2] == find_exports.(:trace!)
      assert [options: 1, options: 2] == find_exports.(:options)
      assert [options!: 1, options!: 2] == find_exports.(:options!)

      assert [request: 1, request: 2] == find_exports.(:request)
      assert [request!: 1, request!: 2] == find_exports.(:request!)
    end

    test "conn/1" do
      {:ok, conn} = User.create_user("abc123", %{foo: "bar"})
      assert conn.host == "localhost"
      assert conn.port == 9000
      assert conn.scheme == "http"
      assert conn.req_path == "/users"
      assert conn.method == :post
      assert conn.adapter == {TestAdapter, nil}
      assert ["Bearer abc123"] == Revolver.Conn.get_req_header(conn, "authorization")
      assert ["application/json"] == Revolver.Conn.get_req_header(conn, "accept")
      assert ["application/json"] == Revolver.Conn.get_req_header(conn, "content-type")
      assert conn.req_body == ~s<{"foo":"bar"}>
      assert conn.owner == self()
    end
  end

  defp configure_client(_) do
    Application.put_env(:test_app, TestClient, [
      adapter: TestAdapter,
      endpoint: "http://localhost:9000",
      headers: [
        {"accept", "application/json"},
        {"content-type", "application/json"}
      ]
    ])

    :ok
  end

  defp define_modules(context) do
    defmodule TestAdapter do
      def conn(config, _opts) do
        %URI{scheme: scheme, host: host, port: port} = URI.parse(config[:endpoint])
        req_headers = config[:headers] || []
        req_path = config[:req_path]

        %Revolver.Conn{
          adapter: {__MODULE__, nil},
          host: host,
          owner: self(),
          port: port,
          req_headers: req_headers,
          req_path: req_path,
          scheme: scheme
        }
      end

      def send_req(conn, _opts) do
        {:ok, conn}
      end
    end

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
        |> put_req_body(params)
        |> post
      end
    end

    {:ok, context}
  end
end
