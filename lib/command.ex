defmodule Heos.Command do
  @moduledoc """
  Heos Commands
  """

  @type conn :: pid | atom
  #
  # Ignoring function ordering
  #

  alias Heos.{Connection, Request, Response}

  # require Logger

  #
  # API
  #

  # @spec parse(
  #         command :: String.t(),
  #         message :: String.t(),
  #         payload :: map
  #       ) :: :ok | {:ok, {atom, any}} | {:error, String.t()}

  ########
  # @command "system/prettify_json_response"
  ########

  # def system_prettify_json_response(enable \\ "on") do
  #   request(@command, %{enable: enable})
  # end

  # def parse(@command, _message, _payload) do
  #   Logger.debug(@command)
  #   :ok
  # end

  # ########
  # @command "system/register_for_change_events"
  # ########

  # def system_register_for_change_events(enable \\ "on") do
  #   Connection.request(@command, %{enable: enable})
  # end

  # def parse(@command, _message, _payload) do
  #   Logger.debug(@command)
  #   :ok
  # end

  # ########
  # @command "player/get_players"
  # ########

  # def player_get_players do
  #   Connection.request(@command)
  # end

  # def parse(@command, message, payload) do
  #   Logger.debug(fn -> "Players: #{inspect(payload)}, #{inspect(message)}" end)

  #   {:ok,
  #    {:players,
  #     for player <- payload do
  #       %Player{
  #         id: player["pid"],
  #         host: player["ip"],
  #         name: player["name"],
  #         model: player["model"],
  #         version: player["version"]
  #       }
  #     end}}
  # end

  # #
  # # Events
  # #

  # #########
  # # @command "event/sources_changed"
  # #########

  # ## Response:
  # ## {
  # ##   "heos": {
  # ##   "command": "event/sources_changed",
  # ##   }
  # ## }

  # # def parse(@command, message, payload) do
  # #  IO.puts("Not implementet, #{@command}: #{inspect(payload)}")
  # #  %{"pid" => pid} = URI.decode_query(message)

  # #  {:ok, {:player, pid, %{}}}
  # # end

  # #########
  # # @command "event/players_changed"
  # #########

  # ## Response:
  # ## {
  # ##   "heos": {
  # ##   "command": "event/players_changed",
  # ##   }
  # ## }

  # # def parse(@command, message, payload) do
  # #  IO.puts("Not implementet, #{@command}: #{inspect(payload)}")
  # #  %{"pid" => pid} = URI.decode_query(message)

  # #  {:ok, {:player, pid, %{}}}
  # # end

  # #########
  # # @command "event/groups_changed"
  # #########

  # ## Response:
  # ## {
  # ##   "heos": {
  # ##   "command": "event/groups_changed",
  # ##   }
  # ## }

  # # def parse(@command, message, payload) do
  # #  IO.puts("Not implementet, #{@command}: #{inspect(payload)}")
  # #  %{"pid" => pid} = URI.decode_query(message)

  # #  {:ok, {:player, pid, %{}}}
  # # end

  # #########
  # # @command "event/player_state_changed"
  # #########

  # # @doc """
  # # Response:
  # # {
  # #  "heos": {
  # #  "command": "event/player_state_changed",
  # #  "message": "pid=<player_id>&state=<play_state>"
  # #  }
  # # }

  # # play_state :: stop | play
  # # """

  # # def parse(@command, message, payload) do
  # #  IO.puts("Not implemented, #{@command}: #{inspect(message)}, #{inspect(payload)}")
  # #  %{"state" => state, "pid" => pid} = URI.decode_query(message)
  # #  {:ok, {:player, pid, %{state: state}}}
  # # end

  # #########
  # # @command "event/player_now_playing_changed"
  # #########

  # # @doc """
  # # Response:
  # # {
  # #  "heos": {
  # #  "command": "event/player_now_playing_changed",
  # #  "message": "pid=<player_id>"
  # #  }
  # # }
  # # """

  # # def parse(@command, message, payload) do
  # #  IO.puts("Not implemented, #{@command}: #{inspect(message)}, #{inspect(payload)}")
  # #  %{"pid" => pid} = URI.decode_query(message)
  # #  {:ok, {:player, pid, %{}}}
  # # end

  # #########
  # # @command "event/player_now_playing_progress"
  # #########

  # # @doc """
  # # Response:
  # # {
  # #  "heos": {
  # #  "command": "event/player_now_playing_changed",
  # #  "message": "pid=<player_id>&cur_pos=<position_ms>&duration=<duration_ms>"
  # #  }
  # # }
  # # """

  # # def parse(@command, message, payload) do
  # #  IO.puts("#{@command}: #{inspect(message)}, #{inspect(payload)}")

  # #  %{"pid" => pid, "cur_pos" => pos, "duration" => dur} = URI.decode_query(message)
  # #  {:ok, {:player, pid, %{duration: dur, position: pos}}}
  # # end

  # #########
  # # @command "event/player_playback_error"
  # #########

  # ## Response:
  # ## {
  # ##   "heos": {
  # ##   "command": "event/player_playback_error",
  # ##   "message": "pid=<player_id>&error=<error>"
  # ##   }
  # ## }

  # # def parse(@command, message, payload) do
  # #  IO.puts("Not implemented, #{@command}: #{inspect(message)}, #{inspect(payload)}")
  # #  %{"pid" => pid} = URI.decode_query(message)
  # #  {:ok, {:player, pid, %{}}}
  # # end

  # #########
  # # @command "event/player_queue_changed"
  # #########

  # ## Response:
  # ## {
  # ##   "heos": {
  # ##   "command": "event/player_queue_changed",
  # ##   "message": "pid=<player_id>"
  # ##   }
  # ## }

  # # def parse(@command, message, payload) do
  # #  IO.puts("Not implemented, #{@command}: #{inspect(message)}, #{inspect(payload)}")
  # #  %{"pid" => pid} = URI.decode_query(message)
  # #  {:ok, {:player, pid, %{}}}
  # # end

  # #########
  # # @command "event/player_volume_changed"
  # #########

  # ## Response:
  # ## {
  # ##   "heos": {
  # ##   "command": "event/player_volume_changed",
  # ##   "message": "pid=<player_id>&level=<vol_level>&mute=<on_or_off>"
  # ##   }
  # ## }

  # # def parse(@command, message, payload) do
  # #  IO.puts("Not implemented, #{@command}: #{inspect(message)}, #{inspect(payload)}")
  # #  %{"pid" => pid} = URI.decode_query(message)
  # #  {:ok, {:player, pid, %{}}}
  # # end

  # #########
  # # @command "event/repeat_mode_changed"
  # #########

  # ## Response:
  # ## {
  # ##   "heos": {
  # ##   "command": "event/repeat_mode_changed",
  # ##   "message": "pid=<player_id>&repeat=<on_all_or_on_one_or_off>”
  # ##   }
  # ## }

  # # def parse(@command, message, payload) do
  # #  IO.puts("Not implemented, #{@command}: #{inspect(message)}, #{inspect(payload)}")
  # #  %{"pid" => pid} = URI.decode_query(message)
  # #  {:ok, {:player, pid, %{}}}
  # # end

  # #########
  # # @command "event/shuffle_mode_changed"
  # #########

  # ## Response:
  # ## {
  # ##   "heos": {
  # ##   "command": "event/repeat_mode_changed",
  # ##   "message": "pid=<player_id>&shuffle=<on_or_off>”
  # ##   }
  # ## }

  # # def parse(@command, message, payload) do
  # #  IO.puts("Not implemented, #{@command}: #{inspect(message)}, #{inspect(payload)}")
  # #  %{"pid" => pid} = URI.decode_query(message)
  # #  {:ok, {:player, pid, %{}}}
  # # end

  # #########
  # # @command "event/group_volume_changed"
  # #########

  # ## Response:
  # ## {
  # ##   "heos": {
  # ##   "command": "event/group_volume_changed",
  # ##   "message": "pid=<player_id>&level=<vol_level>&mute=<on_or_off>"
  # ##   }
  # ## }

  # # def parse(@command, message, payload) do
  # #  IO.puts("Not implemented, #{@command}: #{inspect(message)}, #{inspect(payload)}")
  # #  %{"pid" => pid} = URI.decode_query(message)
  # #  {:ok, {:player, pid, %{}}}
  # # end

  # #########
  # # @command "event/user_changed"
  # #########

  # ## Response:
  # ## {
  # ##   "heos": {
  # ##   "command": "event/user_changed",
  # ##   "message": "signed_out" or "signed_in&un=<current user name>"
  # ##   }
  # ## }

  # # def parse(@command, message, payload) do
  # #  IO.puts("Not implemented, #{@command}: #{inspect(message)}, #{inspect(payload)}")
  # #  %{"pid" => pid} = URI.decode_query(message)
  # #  {:ok, {:player, pid, %{}}}
  # # end

  # def parse(command, message, payload) do
  #   {:error, "unimplemented #{inspect(command)}, #{inspect(message)}, #{inspect(payload)}"}
  # end

  # @doc """
  # request(command, args \\ %{})
  # """
  @spec request(conn, command :: String.t()) :: {:ok, %Response{}} | {:error, term}
  @spec request(conn, command :: String.t(), args :: map) :: {:ok, %Response{}} | {:error, term}
  def request(conn, command, args \\ %{}) do
    req = Request.new(command, args)
    Connection.request(conn, req)
  end
end
