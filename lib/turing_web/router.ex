defmodule TuringWeb.Router do
  use TuringWeb, :router

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
    plug Turing.Auth.Pipeline
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TuringWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/sign_in", SessionController, :sign_in
  end

  scope "/", TuringWeb do
    pipe_through [:browser, :authorized]

    get "/chat", ChatController, :index
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
