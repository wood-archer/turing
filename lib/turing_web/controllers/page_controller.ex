defmodule TuringWeb.PageController do
  use TuringWeb, :controller

  alias Turing.Repo
  alias Turing.Accounts.User

  def sign_in_from_live_view(conn, %{"jwt"=> jwt}) do
    case Turing.Auth.Guardian.resource_from_token(jwt) do
      {:ok, user, _claims} ->
        conn
        |> Turing.Auth.Guardian.Plug.sign_in(user)
        |> redirect(to: Routes.page_path(conn, :index))

      _ ->
        conn
        |> redirect(to: Routes.session_path(conn, :sign_in))

    end
  end

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
