defmodule MomentumHqWeb.SetLocale do
  def on_mount(:default, _params, _session, socket) do
    Gettext.put_locale(MomentumHqWeb.Gettext, "ru")
    {:cont, socket}
  end
end
