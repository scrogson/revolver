defmodule GitHub.Issue do
  import GitHub
  import Revolver.Conn

  def list_issues(owner, repo, query \\ %{}) do
    conn("/repos/#{owner}/#{repo}/issues")
    |> put_query(query)
    |> get
  end
end
