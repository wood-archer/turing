defmodule Turing.Auth.ErrorHandler do

  def auth_error(conn, {type, _reason}, _opts) do
    body = to_string(type)

    conn
    |> Phoenix.Controller.put_flash(:error, body)
    |> Phoenix.Controller.redirect(to: TuringWeb.Router.Helpers.session_path(conn, :sign_in))
    |> Plug.Conn.halt()
  end

end
