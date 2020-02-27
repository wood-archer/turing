defmodule TuringWeb.UserController do
  use TuringWeb, :controller

  def sign_up(conn, _params) do
    Phoenix.LiveView.Controller.live_render(
      conn,
      TuringWeb.Live.SignUp,
      session: %{}
    )
  end

end
