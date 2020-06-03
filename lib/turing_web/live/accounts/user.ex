defmodule TuringWeb.Live.Accounts.User do
  @moduledoc """
      Provides User live functions
  """
  use Phoenix.LiveView
  use Phoenix.HTML
  alias Turing.Accounts.{User, Credential}
  alias Turing.{Accounts, Repo}
  alias TuringWeb.UserView
  alias TuringWeb.Router.Helpers, as: Routes

  def render(assigns) do
    UserView.render("edit.html", assigns)
  end

  def mount(%{"user_id" => id} = _params, _assigns, socket) do
    user = Accounts.get_user!(id) |> Repo.preload([:credential])
    changeset = Accounts.change_user_for_update(user)
    credential_changeset = Accounts.change_credential_update(user.credential)

    {:ok,
     socket
     |> assign(user: user)
     |> assign(changeset: changeset)
     |> assign(credential_changeset: credential_changeset)
     |> assign(type: "PROFILE")}
  end

  def handle_event("change_password", _params, socket) do
    {:noreply, assign(socket, type: "PASSWORD")}
  end

  def handle_event("change_profile", _params, socket) do
    {:noreply, assign(socket, type: "PROFILE")}
  end

  def handle_event("validate_user", %{"user" => params}, socket) do
    changeset =
      %User{}
      |> Accounts.change_user(params)
      |> Map.put(:action, :update)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("validate_credentials", %{"credential" => params}, socket) do
    credential_changeset =
      %Credential{}
      |> Accounts.change_credential_session(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, credential_changeset: credential_changeset)}
  end

  def handle_event("update", %{"user" => params}, %{assigns: %{user: user}} = socket) do
    {:ok, user} =
      user
      |> Accounts.update_user(params)

    changeset = Accounts.change_user_for_update(user)

    {:noreply,
     socket
     |> assign(user: user)
     |> assign(changeset: changeset)}
  end

  def handle_event("update", %{"credential" => params}, %{assigns: %{user: user}} = socket) do
    {:ok, credential} =
      user.credential
      |> Accounts.update_crendential(params)

    credential_changeset = Accounts.change_credential_update(credential)

    {:noreply,
     socket
     |> assign(user: user)
     |> assign(credential_changeset: credential_changeset)}
  end

  def handle_event("navigate_to_dashboard", _params, socket) do
    {:stop,
     socket
     |> redirect(
       to:
         Routes.page_path(
           TuringWeb.Endpoint,
           :index
         )
     )}
  end

  def handle_event("sign_out", _params, socket) do
    {:stop,
     socket
     |> redirect(to: Routes.session_path(TuringWeb.Endpoint, :sign_out))}
  end
end
