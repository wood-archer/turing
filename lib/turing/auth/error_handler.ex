defmodule Turing.Auth.ErrorHandler do

  def auth_error(conn, {:no_resource_found, :no_resource_found}, _opts) do
    redirect_to_signin_page("You must be signed in to access that page.", conn)
  end

  def auth_error(conn, {_type, reason}, _opts) do
    reason
    |> to_string()
    |> redirect_to_signin_page(conn)
  end

  defp redirect_to_signin_page(reason, conn) do
    conn
    |> Phoenix.Controller.put_flash(:error, reason)
    |> Phoenix.Controller.redirect(to: TuringWeb.Router.Helpers.session_path(conn, :sign_in))
    |> Plug.Conn.halt()
  end

end
