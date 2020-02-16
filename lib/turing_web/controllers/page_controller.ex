defmodule TuringWeb.PageController do
  use TuringWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
