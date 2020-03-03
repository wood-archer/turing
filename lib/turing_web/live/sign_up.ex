defmodule TuringWeb.Live.SignUp do
  use Phoenix.LiveView

  alias Turing.Accounts
  alias Turing.Accounts.User
  alias TuringWeb.Router.Helpers, as: Routes

  def mount(_params, _session, socket) do
    {:ok, fetch(socket)}
  end

  def render(assigns) do
    TuringWeb.UserView.render("new.html", assigns)
  end

  def fetch(socket) do
    assign(socket, %{
      changeset: Accounts.change_user(%User{})
    })
  end

  def handle_event("validate", %{"user"=> params}, socket) do
    changeset =
      %User{}
      |> Accounts.change_user(params)
      |> Map.put(:action, :insert)


    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("sign_up", %{"user"=> params}, socket) do
    case Accounts.create_user(params) do
      {:ok, user} ->
        {:stop,
          socket
          |> put_flash(:info, "User signed up successfull!")
          |> redirect(to: Routes.session_path(TuringWeb.Endpoint, :sign_in))
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}

    end
  end
end
