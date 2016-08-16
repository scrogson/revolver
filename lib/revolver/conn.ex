defmodule Revolver.Conn do
  @moduledoc """
  The Revolver Connection.

  This module provides a struct that will be used throughout
  the connection life-cycle.
  """

  alias Revolver.Conn

  defstruct adapter:         {Revolver.Conn, nil},
            host:            "www.example.com",
            method:          :get,
            owner:           nil,
            port:            0,
            private:         %{},
            query_params:    %{},
            query_string:    nil,
            req_body:        "",
            req_cookies:     %{},
            req_headers:     [],
            req_path:        "",
            resp_body:       "",
            resp_cookies:    %{},
            resp_headers:    [],
            scheme:          "http",
            state:           :unset,
            status:          nil

  def put_query(%Conn{} = conn, query) when is_map(query) do
    %{conn | query_params: query}
  end

  def put_req_header(%Conn{req_headers: headers} = conn, key, value) do
    %{conn | req_headers: List.keystore(headers, key, 0, {key, value})}
  end

  def get_req_header(%Conn{req_headers: headers}, key) when is_binary(key) do
    for {k, v} <- headers, k == key, do: v
  end

  def delete_req_header(%Conn{req_headers: headers} = conn, key) when is_binary(key) do
    %{conn | req_headers: List.keydelete(headers, key, 0)}
  end

  def put_resp_header(%Conn{resp_headers: headers} = conn, key, value) do
    %{conn | resp_headers: List.keystore(headers, key, 0, {key, value})}
  end

  def get_resp_header(%Conn{resp_headers: headers}, key) when is_binary(key) do
    for {k, v} <- headers, k == key, do: v
  end

  def delete_resp_header(%Conn{resp_headers: headers} = conn, key) when is_binary(key) do
    %{conn | resp_headers: List.keydelete(headers, key, 0)}
  end

  def put_req_body(conn, body) do
    %{conn | req_body: body}
  end
end
