defmodule TuringWeb.SessionController do
  use TuringWeb, :controller

  def sign_in(conn, _params) do
    Phoenix.LiveView.Controller.live_render(
      conn,
      TuringWeb.Live.Session,
      session: %{}
    )
  end
end
