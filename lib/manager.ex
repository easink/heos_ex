defmodule Heos.Manager do
  @moduledoc """
  Heos Manages handle connection to main device.
  """

  # @compile if Mix.env() == :test, do: :export_all

  # require Logger

  # alias Heos.Connection

  # @port 1255

  # def start_link(args) do
  #  GenServer.start_link(__MODULE__, args, name: __MODULE__)
  # end

  # @impl true
  # def init(args) do
  #  host = Keyword.get(args, :host)
  #  port = Keyword.get(args, :port, @port)

  #  # start discover task
  #  # Task.start(Discover, :discover, [])

  #  send(self(), :connect)

  #  # minimize race condition, or use handle_continue

  #  {:ok,
  #   %{
  #     players: %{},
  #     conn: %Connection{host: host, port: port}
  #   }}
  # end

  #############################################################################
  ##
  ##  API
  ##

  ## @spec add_player(player :: %Player{}) :: {:ok, any}
  ## def add_player(player) do
  ##   GenServer.call(__MODULE__, {:add_player, player})
  ## end

  #############################################################################
  ##
  ##  Callbacks
  ##

  # @impl true
  # def handle_info(:connect, state) do
  #  # players = state.players
  #  # updated_players = update_players(players, player)

  #  # {:reply, updated_players, %{state | players: updated_players}}
  #  {:noreply, state}
  # end

  #############################################################################
  ##
  ##  Private
  ##

  ## @doc """
  ## update_players(players, player)

  ## iex> player1 = %{id: "111", name: "test name"}
  ## iex> players = %{"111" => %{id: "111", name: "test name"}}
  ## iex> update_players(players, player1)
  ## iex> %{"111" => %{id: "111", name: "test name"}}

  ## """
  ## defp update_players(players, player) do
  ##   Map.update(players, player.id, player, & &1)
  ##   # case Map.get(players, player.id) do
  ##   #   nil -> %{players | player.id => player}
  ##   #   _ -> players
  ##   # end
  ## end
end
