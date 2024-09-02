import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

if config_env() == :prod do
  defmodule Helpers do
    def get_env(name) do
      case System.get_env(name) do
        nil -> raise "Environment variable #{name} is not set!"
        val -> val
      end
    end
  end

  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  config :momentum_hq, MomentumHq.Repo,
    # ssl: true,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "20"),
    parameters: [
      tcp_keepalives_idle: "60",
      tcp_keepalives_interval: "5",
      tcp_keepalives_count: "3"
    ],
    socket_options: [keepalive: true]

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = "momentum.markevich.money"

  config :momentum_hq, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  config :momentum_hq, MomentumHqWeb.Endpoint,
    server: true,
    force_ssl: [hsts: true],
    url: [host: host, port: 8443, scheme: "https"],
    https: [
      port: 8443,
      cipher_suite: :strong,
      keyfile: Helpers.get_env("MOMENTUM_SSL_KEY_PATH"),
      certfile: Helpers.get_env("MOMENTUM_SSL_CERT_PATH")
    ],
    secret_key_base: secret_key_base

  config(:telegram,
    client_bot_token: Helpers.get_env("CLIENT_BOT_TOKEN"),
    admin_bot_token: Helpers.get_env("ADMIN_BOT_TOKEN"),
    admin_chat_id: Helpers.get_env("ADMIN_CHAT_ID")
  )
end
