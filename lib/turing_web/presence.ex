defmodule TuringWeb.Presence do
  use Phoenix.Presence,
    otp_app: :turing,
    pubsub_server: Turing.PubSub
end
