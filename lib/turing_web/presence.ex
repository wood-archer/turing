defmodule TuringWeb.Presence do
  @moduledoc """
  Provides Presence functions
  """

  use Phoenix.Presence,
    otp_app: :turing,
    pubsub_server: Turing.PubSub
end
