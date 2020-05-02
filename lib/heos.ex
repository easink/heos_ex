defmodule Heos do
  @moduledoc """
  Heos Library.
  """

  @type conn :: pid() | atom
  # use GenServer
  require Logger

  # alias Heos.Command
  # alias Heos.Player
  # alias Heos.Discover

  # @port 1255

  # defstruct active_player: nil,
  #           socket: nil,
  #           pid: nil

  #
  # API
  #

  defdelegate start_link(args), to: Heos.Connection
  defdelegate connect(conn), to: Heos.Connection
  defdelegate subscribe(), to: Heos.Events
  defdelegate discover(), to: Heos.Discover

  @spec simple() :: {:ok, conn}
  def simple() do
    conn = :heos
    {:ok, ip} = Heos.discover()
    {:ok, _pid} = Heos.start_link(host: ip, name: conn)
    :ok = Heos.connect(conn)
    {:ok, :off} = Heos.Commands.System.prettify_json_response(conn, :off)
    :ok = Heos.Commands.System.heart_beat(conn)
    {:ok, :on} = Heos.Commands.System.register_for_change_events(conn, :on)
    {:ok, conn}
  end

  def watch() do
    {:ok, conn} = simple()

    spawn(fn ->
      subscribe()
      receiver(conn)
    end)

    :ok
  end

  defp receiver(conn) do
    receive do
      {:event, %{command: "player_now_playing_changed", pid: player_id}} ->
        {:ok, media} = Heos.Commands.Player.get_now_playing_media(conn, player_id)
        Logger.info("MEDIA: #{inspect(media)}")

        receiver(conn)

      event ->
        Logger.info("SIMPLE EVENT: #{inspect(event)}")
        receiver(conn)
    end
  end
end
