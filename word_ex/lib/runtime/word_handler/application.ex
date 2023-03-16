defmodule WordEx.Runtime.WordHandler.Application do
  use Application

  def start(_type, _args) do
    children = [{WordEx.Runtime.WordHandler.Server, []}]

    options = [
      name: WodrdEx.Runtime.Supervisor,
      strategy: :one_for_one
    ]

    Supervisor.start_link(children, options)
  end
end
