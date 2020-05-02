defmodule Heos.Supervisor do
  @moduledoc """
  Heos Supervisor.
  """
  use Supervisor

  def start_link(opts \\ []) do
    # need only one client (i.e. :name)
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    children = [
      {Registry, keys: :duplicate, name: Heos.Events},
      # {Heos.Manager, args} iso Connection
      {Heos.Connection, opts}
    ]

    opts = [strategy: :rest_for_one]

    Supervisor.init(children, opts)
  end
end
