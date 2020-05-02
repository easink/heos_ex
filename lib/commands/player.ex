defmodule Heos.Commands.Player do
  @moduledoc false

  @type player_id :: integer
  @type play_state :: :play | :pause | :stop
  @type conn :: pid() | atom

  ## # API
  ## #

  alias Heos.{Command, Response}

  #########
  @command "player/get_players"
  @doc """

  Attribute | Description                                      | Enumeration
  ----------+--------------------------------------------------+---------------------
  pid       | Player id                                        | N/A
  gid       | pid of the Group leader                          | N/A
  network   | Network connection type                          | * wired
            |                                                  | * wifi
            |                                                  | * unknown (not applicable for external controllers)
  lineout   | LineOut level type                               | 1 - variable
            |                                                  | 2 - Fixed
  control   | Only valid when lintout level type is Fixed (2). | 1 - None
            |                                                  | 2 - IR
            |                                                  | 3 - Trigger
            |                                                  | 4 - Network
  serial    | Only listed if device has valid serial number    | N/A


  """
  @spec get_players(conn) :: {:ok, map} | {:error, term}
  def get_players(conn) do
    # {:ok, resp} -> {:ok, Enum.map(resp.payload, &Util.to_struct(Player, &1))}

    with {:ok, response} <- Command.request(conn, @command) do
      players =
        for player <- response.payload, into: %{} do
          {player["pid"], player}
        end

      {:ok, players}
    end
  end

  #########
  @command "player/get_player_info"

  def get_player_info(conn, player_id) do
    with {:ok, resp} <- Command.request(conn, @command, %{pid: player_id}),
         do: {:ok, resp.payload}
  end

  #########
  @command "player/get_play_state"

  def get_play_state(conn, player_id) do
    with {:ok, resp} <- Command.request(conn, @command, %{pid: player_id}) do
      play_state =
        resp.message
        |> Response.parse_message(state: [:play, :pause, :stop])
        |> Map.get(:state)

      {:ok, play_state}
    end
  end

  #########
  @command "player/set_play_state"

  @spec set_play_state(conn, player_id, play_state) :: {:ok, play_state} | {:error, term}
  def set_play_state(conn, player_id, play_state) do
    with {:ok, resp} <- Command.request(conn, @command, %{pid: player_id, state: play_state}) do
      play_state =
        resp.message
        |> Response.parse_message(state: [:play, :pause, :stop])
        |> Map.get(:state)

      {:ok, play_state}
    end
  end

  #########
  @command "player/get_now_playing_media"

  @doc """
  Get now playing media.

  Ignore Options for now.

  Returns `{:ok, map}`.

  ## Examples

      iex> Heos.Commands.Player.get_now_playing_media(conn, 1)
      {:ok, %{...}}

  """
  @spec get_now_playing_media(conn, player_id) :: term
  def get_now_playing_media(conn, player_id) do
    with {:ok, response} <- Command.request(conn, @command, %{pid: player_id}),
         do: {:ok, response.payload}
  end

  #########
  @command "player/get_volume"

  def get_volume(conn, player_id) do
    with {:ok, response} <- Command.request(conn, @command, %{pid: player_id}) do
      level =
        response.message
        |> Response.parse_message()
        |> Map.get("level")
        |> String.to_integer()

      {:ok, level}
    end
  end

  #########
  @command "player/set_volume"

  @spec set_volume(conn, player_id, 0..100) :: {:ok, 0..100} | {:error, term}
  def set_volume(conn, player_id, level) do
    level = level |> max(0) |> min(100)

    with {:ok, response} <- Command.request(conn, @command, %{pid: player_id, level: level}) do
      level =
        response.message
        |> Response.parse_message()
        |> Map.get("level")
        |> String.to_integer()

      {:ok, level}
    end
  end

  #########
  @command "player/volume_up"

  def volume_up(_conn) do
    {:error, :not_implemented}
  end

  #########
  @command "player/volume_down"

  def volume_down(_conn) do
    {:error, :not_implemented}
  end

  #########
  @command "player/get_mute"

  def get_mute(_conn) do
    {:error, :not_implemented}
  end

  #########
  @command "player/set_mute"

  def set_mute(_conn) do
    {:error, :not_implemented}
  end

  #########
  @command "player/toggle_mute"

  def toggle_mute(_conn) do
    {:error, :not_implemented}
  end

  #########
  @command "player/get_play_mode"

  def get_play_mode(_conn) do
    {:error, :not_implemented}
  end

  #########
  @command "player/set_play_mode"

  def set_play_mode(_conn) do
    {:error, :not_implemented}
  end

  #########
  @command "player/get_queue"

  def get_queue(_conn) do
    {:error, :not_implemented}
  end

  #########
  @command "player/play_queue"

  def play_queue(_conn) do
    {:error, :not_implemented}
  end

  #########
  @command "player/remove_from_queue"

  def remove_from_queue(_conn) do
    {:error, :not_implemented}
  end

  #########
  @command "player/save_queue"

  def save_queue(_conn) do
    {:error, :not_implemented}
  end

  #########
  @command "player/clear_queue"

  def clear_queue(_conn) do
    {:error, :not_implemented}
  end

  #########
  @command "player/move_queue_item"

  def move_queue_item(_conn) do
    {:error, :not_implemented}
  end

  #########
  @command "player/play_next"

  def play_next(_conn) do
    {:error, :not_implemented}
  end

  #########
  @command "player/play_previous"

  def play_previous(_conn) do
    {:error, :not_implemented}
  end

  #########
  @command "player/set_quickselect"

  def set_quickselect(_conn) do
    {:error, :not_implemented}
  end

  #########
  @command "player/play_quickselect"

  def play_quickselect(_conn) do
    {:error, :not_implemented}
  end

  #########
  @command "player/get_quickselects"

  def get_quickselects(_conn) do
    {:error, :not_implemented}
  end

  #########
  @command "player/check_update"

  def check_update(_conn) do
    {:error, :not_implemented}
  end
end
