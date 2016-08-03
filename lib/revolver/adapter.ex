defmodule Revolver.Adapter do
  @callback conn(Keyword.t) :: Revolver.Conn.t
  @callback send_req(Revolver.Conn.t) :: {:ok, Revolver.Conn.t}
end
