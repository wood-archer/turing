defmodule TuringWeb.Live.SignUp do
  @moduledoc """
  Provides SignUp live functions
  """
  use Phoenix.LiveView

  alias Turing.Accounts
  alias Turing.Accounts.User
  alias TuringWeb.Router.Helpers, as: Routes

  def mount(_params, _session, socket) do
    {:ok, fetch(socket) |> assign(sign_up_view: :email_password_view)}
  end

  def render(assigns) do
    TuringWeb.UserView.render("new.html", assigns)
  end

  def fetch(socket) do
    assign(socket, %{
      changeset: Accounts.change_user(%User{})
    })
  end

  def handle_event("validate", %{"user" => params}, socket) do
    changeset =
      %User{}
      |> Accounts.change_user(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("go_back_to_emal_password_view", _params, socket) do
    {:noreply, socket |> assign(sign_up_view: :email_password_view)}
  end

  def handle_event("sign_up", %{"user" => params}, socket) do
    case Accounts.setup_user(params) do
      {:ok, _user} ->
        {:noreply,
         socket
         # |> put_flash(:info, "User signed up successfull!")
         # |> assign(sign_up_view: :avatar_upload_view)}

         |> redirect(to: Routes.session_path(TuringWeb.Endpoint, :sign_in))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  # Catch all event to prevent sign_up event without user params.
  def handle_event(_, _, socket), do: {:noreply, socket}
end
