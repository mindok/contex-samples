defmodule ContexSampleWeb.PageController do
  use ContexSampleWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
