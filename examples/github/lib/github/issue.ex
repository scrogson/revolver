defmodule GitHub.Issue do
  import GitHub
  import Revolver.Conn

  def list_issues(owner, repo, query \\ nil) do
    conn()
    |> put_query(query)
    |> get("/repos/#{owner}/#{repo}/issues")
  end
end
