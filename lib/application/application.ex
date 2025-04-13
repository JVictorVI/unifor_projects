defmodule KojimaBot.Application do

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      KojimaBot
    ]

    opts = [strategy: :one_for_one, name: KojimaBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
