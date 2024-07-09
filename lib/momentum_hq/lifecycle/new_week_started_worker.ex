defmodule MomentumHq.Lifecycle.NewWeekStartedWorker do
  use Oban.Worker, queue: :lifecycle, max_attempts: 1

  alias MomentumHq.Blueprinting
  alias MomentumHq.Lifecycle
  alias MomentumHq.Telegram

  @impl Oban.Worker
  def perform(_job) do
    blueprints = Blueprinting.list_momentum_blueprints()

    blueprints
    |> Enum.each(fn momentum_blueprint ->
      Lifecycle.schedule_current_momentum_creation(momentum_blueprint)
    end)

    Telegram.send_admin_message_async(%{
      text:
        Telegram.escape_telegram_markdown(
          "Заскедулил создание новых current momentum'ов\\. Количество блюпринтов: #{length(blueprints)}"
        )
    })

    :ok
  end
end
