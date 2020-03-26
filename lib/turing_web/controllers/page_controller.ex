defmodule TuringWeb.PageController do
  use TuringWeb, :controller

  def index(conn, _params) do
    current_user = Turing.Auth.Guardian.Plug.current_resource(conn)
    render(conn, "index.html", current_user: current_user)
  end
end
