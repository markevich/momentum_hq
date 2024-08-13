# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :momentum_hq,
  ecto_repos: [MomentumHq.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :momentum_hq, MomentumHqWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: MomentumHqWeb.ErrorHTML, json: MomentumHqWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: MomentumHqPubSub,
  live_view: [signing_salt: "U5iIafr/"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :momentum_hq, MomentumHq.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  momentum_hq: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.0",
  momentum_hq: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :momentum_hq, MomentumHq.Repo, migration_primary_key: [type: :uuid]

config :momentum_hq, Oban,
  engine: Oban.Engines.Basic,
  plugins: [
    {Oban.Plugins.Cron,
     crontab: [
       {"0 8 * * *", MomentumHq.Lifecycle.NewDayStartedWorker},
       {"0 5 * * 1", MomentumHq.Lifecycle.NewWeekStartedWorker}
     ]},
    {Oban.Plugins.Pruner, max_age: 60 * 60 * 24 * 30},
    {Oban.Plugins.Lifeline, rescue_after: :timer.minutes(30)}
  ],
  queues: [
    default: 5,
    lifecycle: 3,
    telegram: 1
  ],
  repo: MomentumHq.Repo

config :momentum_hq, MomentumHqWeb.Gettext, default_locale: "ru"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
