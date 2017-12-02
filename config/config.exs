# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :chat_gdg,
  ecto_repos: [ChatGdg.Repo]

# Configures the endpoint
config :chat_gdg, ChatGdgWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "NlJYR/Y1zE93ITLRD+SnV6Uv8Z1XCBjzTEcH/kPsZKmcnYwoNoDDzj4XZeFUq85w",
  render_errors: [view: ChatGdgWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ChatGdg.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
config :guardian, Guardian,
  allowed_algos: ["HS512"], # optional
  verify_module: Guardian.JWT, # optional
  issuer: "ChatGdg",
  ttl: {30, :days},
  allowed_drift: 2000,
  verify_issuer: true, # optional
  secret_key: "dY3otygFOMcX1zXEwQ11JFIQdZp0Z+C0xEF1lx5gOpef/mYrsWu28dW++FBvm7qi",
  serializer: ChatGdg.GuardianSerializer

import_config "#{Mix.env}.exs"
