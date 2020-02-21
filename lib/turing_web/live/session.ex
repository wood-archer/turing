defmodule TuringWeb.Live.Session do
  use Phoenix.LiveView

  alias Turing.{Accounts, Accounts.Credential}
  alias Turing.Auth
  alias TuringWeb.Router.Helpers, as: Routes

  def mount(_params, _session, socket) do
    {:ok, fetch(socket)}
  end

  def render(assigns) do
    TuringWeb.SessionView.render("index.html", assigns)
  end

  def fetch(socket) do
    assign(socket, %{
      changeset: Accounts.change_credential_session(%Credential{})
    })
  end

  def handle_event("validate", %{"credential"=> params}, socket) do
    changeset =
      %Credential{}
      |> Accounts.change_credential_session(params)
      |> Map.put(:action, :insert)


    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("sign_in", %{"credential"=> params}, socket) do
    case Auth.validate_credentials(params["email"], params["password"]) do
      {:ok, user} ->
        {:stop,
         socket
         |> put_flash(:info, "User signed in successfull!")
         |> redirect(to: Routes.chat_path(TuringWeb.Endpoint, :index))
        }

      {:error, errors} ->
        %Phoenix.LiveView.Socket{
          assigns: %{changeset: changeset}
        } = socket

        {:noreply, assign(socket, changeset: Map.put(changeset, :errors, errors))}

    end
  end
end
