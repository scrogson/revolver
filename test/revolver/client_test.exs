defmodule Revolver.ClientTest do
  use ExUnit.Case, async: true

  alias Revolver.ClientTest.{TestAdapter, TestClient, User}

  describe "TestClient" do
    setup [:configure_client, :define_modules]

    test "it exports http verb functions and base request function" do
      exports = TestClient.__info__(:exports)
      find_exports = fn key -> Enum.filter(exports, fn {k, _} -> key == k end) end

      assert [conn: 0, conn: 1] == find_exports.(:conn)

      assert [get: 2, get: 3] == find_exports.(:get)
      assert [get!: 2, get!: 3] == find_exports.(:get!)
      assert [post: 2, post: 3] == find_exports.(:post)
      assert [post!: 2, post!: 3] == find_exports.(:post!)
      assert [put: 2, put: 3] == find_exports.(:put)
      assert [put!: 2, put!: 3] == find_exports.(:put!)
      assert [patch: 2, patch: 3] == find_exports.(:patch)
      assert [patch!: 2, patch!: 3] == find_exports.(:patch!)
      assert [delete: 2, delete: 3] == find_exports.(:delete)
      assert [delete!: 2, delete!: 3] == find_exports.(:delete!)
      assert [head: 2, head: 3] == find_exports.(:head)
      assert [head!: 2, head!: 3] == find_exports.(:head!)
      assert [trace: 2, trace: 3] == find_exports.(:trace)
      assert [trace!: 2, trace!: 3] == find_exports.(:trace!)
      assert [options: 2, options: 3] == find_exports.(:options)
      assert [options!: 2, options!: 3] == find_exports.(:options!)

      assert [request: 2, request: 3] == find_exports.(:request)
      assert [request!: 2, request!: 3] == find_exports.(:request!)
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
      host: "http://localhost:9000",
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
        %URI{scheme: scheme, host: host, port: port} = URI.parse(config[:host])
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

      def send_req(conn, path, _opts) do
        {:ok, %{conn | req_path: path}}
      end
    end

    defmodule TestClient do
      use Revolver.Client, otp_app: :test_app
    end

    defmodule User do
      import TestClient
      import Revolver.Conn

      def list_users do
        conn()
        |> get("/users")
      end

      def create_user(token, params \\ %{}) do
        conn()
        |> put_req_header("authorization", "Bearer " <> token)
        |> put_req_body(params)
        |> post("/users")
      end
    end

    {:ok, context}
  end
end
