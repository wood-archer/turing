defmodule TuringWeb.SessionController do
  use TuringWeb, :controller

  alias Turing.Accounts.User
  alias Turing.Auth.Guardian

  def sign_in(conn, %{"jwt"=> jwt}) do
    case Guardian.resource_from_token(jwt) do
      {:ok, %User{} = user, _claims} ->
        conn
        |> Guardian.Plug.sign_in(user)
        |> redirect(to: Routes.page_path(conn, :index))

      _ ->
        conn
        |> redirect(to: Routes.session_path(conn, :sign_in))

    end
  end

  def sign_in(conn, _params) do
    Phoenix.LiveView.Controller.live_render(
      conn,
      TuringWeb.Live.Session,
      session: %{}
    )
  end

end
