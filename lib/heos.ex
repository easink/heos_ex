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

  # @type socket :: :gen_tcp.socket()
  # @type socket :: :inet.socket()

  # @type host_address :: :inet.socket_address() | :inet.hostname()
  # @type host_port :: :inet.port_number()

  # @type t :: %__MODULE__{
  #         active_player: %Player{},
  #         socket: socket,
  #         pid: pid()
  #       }

  #
  # API
  #

  @spec simple() :: {:ok, conn}
  def simple() do
    conn = Heos.Connection
    {:ok, ip} = Heos.Discover.discover()
    {:ok, _pid} = Heos.Supervisor.start_link(host: ip, name: conn)
    :ok = Heos.Connection.connect(conn)
    {:ok, :off} = Heos.Commands.System.prettify_json_response(conn, :off)
    :ok = Heos.Commands.System.heart_beat(conn)
    {:ok, :on} = Heos.Commands.System.register_for_change_events(conn, :on)
    {:ok, conn}
  end

  defdelegate start_link(args), to: Heos.Supervisor
  defdelegate connect(conn), to: Heos.Connection
  defdelegate subscribe(), to: Heos.Events
  defdelegate discover(), to: Heos.Discover

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
