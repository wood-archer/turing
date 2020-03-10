defmodule TuringWeb.DashboardView do
  use TuringWeb, :view

  def remove_member_link(contacts, user_id, current_user_id) do
    username =
      contacts
      |> Enum.find(&(&1.id == user_id))
      |> Map.get(:first_name) # TODO: preload credential and use username instead

    link("#{username} #{if user_id == current_user_id, do: "(me)", else: "✖"} ",
      to: "#!",
      phx_click: unless(user_id == current_user_id, do: "remove_member"),
      phx_value_user_id: user_id
    )
  end

  def add_member_link(user) do
    link(
      user.first_name,
      to: "#!",
      phx_click: "add_member",
      phx_value_user_id: user.id
    )
  end

  def contacts_except(contacts, current_user) do
    Enum.reject(contacts, &(&1.id == current_user.id))
  end

  def disable_create_button?(assigns) do
    Enum.count(assigns[:conversation_changeset].changes[:conversation_members]) < 2
  end
end
