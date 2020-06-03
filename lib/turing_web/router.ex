defmodule TuringWeb.Router do
  use TuringWeb, :router

  use Plug.ErrorHandler
  use Sentry.Plug

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Phoenix.LiveView.Flash
  end

  pipeline :graphql do
    plug(:accepts, ["json"])
    plug(TuringWeb.Context)
  end

  pipeline :authorized do
    plug :fetch_session

    plug Guardian.Plug.Pipeline,
      module: Turing.Auth.Guardian,
      error_handler: Turing.Auth.ErrorHandler

    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TuringWeb do
    pipe_through [:browser, :authorized]

    get "/", PageController, :index

    live "/chat/conversations/:conversation_id/users/:user_id", Live.Chat.Conversation, as: :chat
    live "/leaderboard", Live.Leaderboard, as: :leaderboard
    live "/profile/edit", Live.Accounts.User, as: :user
    delete "/sign_in", SessionController, :sign_out
  end

  scope "/", TuringWeb do
    pipe_through :browser

    get "/sign_in", SessionController, :sign_in
    get "/sign_up", UserController, :sign_up
  end

  if Mix.env() == :dev do
    scope "/graphiql" do
      forward("/", Absinthe.Plug.GraphiQL, schema: Turing.Graphql.Schema)
    end
  end

  scope "/api" do
    pipe_through(:graphql)

    forward("/", Absinthe.Plug, schema: Turing.Graphql.Schema)
  end

  # Other scopes may use custom stacks.
  # scope "/api", TuringWeb do
  #   pipe_through :api
  # end
end
