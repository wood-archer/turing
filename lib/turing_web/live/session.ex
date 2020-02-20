defmodule TuringWeb.Live.Session do
  use Phoenix.LiveView

  alias Turing.{Accounts, Accounts.Credential}

  def mount(_params, _session, socket) do
    {:ok, fetch(socket)}
  end

  def render(assigns) do
    TuringWeb.SessionView.render("index.html", assigns)
  end

  def fetch(socket) do
    assign(socket, %{
      changeset: Accounts.change_credential(%Credential{})
    })
  end

  def handle_event("validate", %{"credential"=> params}, socket) do
    changeset =
      %Credential{}
      |> Accounts.change_credential(params)
      |> Map.put(:action, :insert)


    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("sign_in", %{"credential"=> params}, socket) do
    
  end
end
