defmodule TuringWeb.SessionController do
  use TuringWeb, :controller

  def sign_in(conn, params) do
    Phoenix.LiveView.Controller.live_render(
      conn,
      TuringWeb.Live.Session,
      session: %{}
    )
  end
end
