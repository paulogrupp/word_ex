defmodule WordEx.Runtime.Application do
  @super_name GameStarter

  use Application

  def start(_type, _args) do
    supervisor_spec = [
      {DynamicSupervisor, name: @super_name, strategy: :one_for_one},
      {DynamicSupervisor, name: WordHandler, strategy: :one_for_one}
    ]

    Supervisor.start_link(supervisor_spec, strategy: :one_for_one)
    DynamicSupervisor.start_child(WordHandler, {WordEx.Runtime.WordHandler.Server, nil})
  end

  def start_game do
    DynamicSupervisor.start_child(@super_name, {WordEx.Runtime.Server, nil})
  end
end
