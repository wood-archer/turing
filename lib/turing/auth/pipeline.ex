defmodule Turing.Auth.Pipeline do
  use Guardian.Plug.Pipeline, otp_app: :turing,
                              module: Turing.Guardian,
                              error_handler: Turing.Auth.ErrorHandler

    plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}, realm: "Bearer"
    plug Guardian.Plug.EnsureAuthenticated
    plug Guardian.Plug.LoadResource, ensure: true, allow_blank: true
end