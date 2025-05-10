defmodule AddressBookEcto.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AddressBookEcto.Repo
      # Starts a worker by calling: AddressBookEcto.Worker.start_link(arg)
      # {AddressBookEcto.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AddressBookEcto.Supervisor]
    Supervisor.start_link(children, opts)

    # Start the AddressBookEcto main loop in a separate process (Task)
    # This keeps the main application supervisor running.
    Task.start(fn -> AddressBookEcto.run() end)
  end
end
