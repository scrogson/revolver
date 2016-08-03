defmodule Revolver.Client do
  @moduledoc """
  """

  @methods [:get, :post, :put, :patch, :delete, :options, :head, :trace]

  defmacro __using__(opts) do
    quote do
      unquote(generate_http_functions())
      unquote(generate_request_functions(opts))
    end
  end

  defp generate_http_functions do
    for method <- @methods do
      quote do
        def unquote(method)(conn, opts \\ []) do
          request(%{conn | method: unquote(method)}, opts)
        end

        def unquote(String.to_atom(to_string(method) <> "!"))(conn, opts \\ []) do
          request!(%{conn | method: unquote(method)}, opts)
        end
      end
    end
  end

  defp generate_request_functions(opts) do
    quote do
      @otp_app unquote(opts)[:otp_app] || raise "Revolver.Client expects :otp_app to be given"
      @config Application.get_env(@otp_app, __MODULE__, [])
      @adapter unquote(opts)[:adapter] || @config[:adapter]

      def config, do: @config
      def adapter, do: @adapter

      def conn(path) do
        @adapter.conn(Keyword.merge(@config, [req_path: path]))
      end

      def request(conn, opts \\ []) do
        {body, opts} = Keyword.pop(opts, :body, conn.req_body)
        {meth, opts} = Keyword.pop(opts, :method, conn.method)

        @adapter.send_req(%{conn | method: meth, req_body: body})
      end

      def request!(conn, opts \\ []) do
        case request(conn, opts) do
          {:ok, response} -> response
          {:error, error} -> raise error
        end
      end
    end
  end
end
