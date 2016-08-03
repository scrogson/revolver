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
    quote bind_quoted: [opts: opts] do
      @otp_app opts[:otp_app] || raise "Revolver.Client expects :otp_app to be given"
      @config Application.get_env(@otp_app, __MODULE__, [])
      @adapter opts[:adapter] || @config[:adapter]

      def config, do: @config
      def adapter, do: @adapter

      def conn(path) do
        @adapter.conn(Keyword.merge(@config, [req_path: path]))
      end

      def request(conn, opts \\ []) do
        with {:ok, conn} <- encode_req_body(conn),
             {:ok, conn} <- @adapter.send_req(conn),
             {:ok, conn} <- decode_resp_body(conn) do
          {:ok, conn}
       end
      end

      def request!(conn, opts \\ []) do
        case request(conn, opts) do
          {:ok, response} -> response
          {:error, error} -> raise error
        end
      end

      defp encode_req_body(%{req_body: ""} = conn), do: {:ok, conn}
      defp encode_req_body(%{req_body: body} = conn) when body == %{} do
        {:ok, %{conn | req_body: ""}}
      end
      defp encode_req_body(%{req_body: body, req_headers: headers} = conn) do
        case get_content_type(headers) do
          "application/x-www-form-urlencoded" ->
            {:ok, %{conn | req_body: URI.encode_query(body)}}
          content_type ->
            if serializer = get_serializer(content_type) do
              {:ok, %{conn | req_body: serializer.encode!(body)}}
            else
              {:ok, conn}
            end
        end
      end

      defp decode_resp_body(%{resp_body: ""} = conn), do: {:ok, conn}
      defp decode_resp_body(%{resp_body: " "} = conn), do: {:ok, conn}
      defp decode_resp_body(%{resp_body: body, resp_headers: headers} = conn) do
        case get_content_type(headers) do
          "application/x-www-form-urlencoded" ->
            {:ok, %{conn | resp_body: URI.decode_query(body)}}
          content_type ->
            if serializer = get_serializer(content_type) do
              {:ok, %{conn | resp_body: serializer.decode!(body)}}
            else
              {:ok, conn}
            end
        end
      end

      defp get_serializer(content_type) do
        Application.get_env(:revolver, :serializers)[content_type]
      end

      defp get_content_type(headers) do
        case List.keyfind(headers, "content-type", 0) do
          {"content-type", ct} ->
            case Plug.Conn.Utils.content_type(ct) do
              {:ok, type, subtype, _} ->
                "#{type}/#{subtype}"
              :error ->
                nil
            end
          nil ->
            nil
        end
      end
    end
  end
end
