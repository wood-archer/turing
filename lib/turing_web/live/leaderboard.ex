defmodule TuringWeb.Live.Leaderboard do
  @moduledoc """
  Provides Dashboard live functions
  """
  require Logger
  use Phoenix.LiveView
  use Phoenix.HTML
  alias Turing.{Repo, Accounts.User}
  import Ecto.Query
  alias TuringWeb.Router.Helpers, as: Routes

  def render(assigns) do
    ~L"""
        <div>
            <div class="leader-header-section">
                <div class="btn-org signin">
                    <button phx-click="navigate_to_dashboard"><svg version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"
                        viewBox="0 0 341.333 341.333" style="enable-background:new 0 0 341.333 341.333;" xml:space="preserve">
                <g>
                    <g>
                        <polygon points="170.667,0 140.48,30.187 259.627,149.333 0,149.333 0,192 259.627,192 140.48,311.147 170.667,341.333
                            341.333,170.667 		"/>
                    </g>
                </g>
                </svg></button>
                </div>
                <h1>
                    Leaderboard
                </h1>
            </div>
            <table class="leader-table">
            <th>Name</th><th>Coins</th>
            <%= for user <- @users do %>                    
                <tr>
                    <td><%= Enum.join([user.first_name, user.last_name], " ") %></td>
                    <td><%= user.coins %></td>
                </tr>                    
            <% end %>
            </table>
        </div>
    """
  end

  def mount(params, _assigns, socket) do
    users =
      from(u in User,
        join: ca in assoc(u, :coin_account),
        order_by: [desc: ca.balance],
        select: %{first_name: u.first_name, last_name: u.last_name, coins: ca.balance}
      )
      |> Repo.all()

    {:ok,
     socket
     |> assign(users: users)}
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
end
