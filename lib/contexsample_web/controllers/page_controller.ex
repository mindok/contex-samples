defmodule ContexSampleWeb.PageController do
  use ContexSampleWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end

  def faq(conn, _params) do
    render(conn, :faq)
  end
end
