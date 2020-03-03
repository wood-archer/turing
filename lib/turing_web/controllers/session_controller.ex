defmodule TuringWeb.SessionController do
  use TuringWeb, :controller

  alias Turing.Repo
  alias Turing.Accounts.User
  alias Turing.Auth.Guardian

  def sign_in(conn, %{"token"=> token}) do
    case Phoenix.Token.verify(TuringWeb.Endpoint, secret_key_base(), token, max_age: 86400) do
      {:ok, user_id} ->
        user = Repo.get(User, user_id)

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
      TuringWeb.Live.SignIn,
      session: %{}
    )
  end

  def sign_out(conn, _params) do
    conn
    |> put_flash(:info, "We'll miss you!")
    |> Guardian.Plug.sign_out()
    |> redirect(to: Routes.session_path(conn, :sign_in))
  end

  defp secret_key_base do
    Application.get_env(:turing, TuringWeb.Endpoint)[:secret_key_base]
  end

end
