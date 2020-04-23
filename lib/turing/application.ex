defmodule Turing.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      Turing.Repo,
      # Start the endpoint when the application starts
      TuringWeb.Endpoint,
      # Guardian DB worker for sweeping out and cleaning outdated tokens
      Guardian.DB.Token.SweeperServer,
      # track online users
      TuringWeb.Presence,
      # Starts a worker by calling: Turing.Worker.start_link(arg)
      # {Turing.Worker, arg},
      Turing.Chat.WaitingRoom
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Turing.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    TuringWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
