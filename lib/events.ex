defmodule Heos.Events do
  @moduledoc false

  @topic "events"

  @type conn :: pid() | atom

  alias Heos.Response

  @spec subscribe() :: {:ok, conn()} | {:error, {:already_registered, conn()}}
  def subscribe() do
    Registry.register(Heos.Events, @topic, [])
  end

  @spec publish(map) :: :ok
  def publish(event) do
    Registry.dispatch(Heos.Events, @topic, fn entries ->
      for {pid, _} <- entries, do: send(pid, {:event, event})
    end)
  end

  @spec publish(String.t(), String.t()) :: :ok
  def publish("sources_changed" = command, _message),
    do: publish(%{command: command})

  def publish("players_changed" = command, _message),
    do: publish(%{command: command})

  def publish("groups_changed" = command, _message),
    do: publish(%{command: command})

  def publish("player_state_changed" = command, message) do
    message
    |> Response.parse_message(pid: :number, state: [:play, :pause, :stop])
    |> Map.put(:command, command)
    |> publish()
  end

  def publish("player_now_playing_changed" = command, message) do
    message
    |> Response.parse_message(pid: :number)
    |> Map.put(:command, command)
    |> publish()
  end

  def publish("player_now_playing_progress" = command, message) do
    message
    |> Response.parse_message(pid: :number, cur_pos: :number, duration: :number)
    |> Map.put(:command, command)
    |> publish()
  end

  def publish("player_playback_error" = command, message) do
    message
    |> Response.parse_message(pid: :number, error: :string)
    |> Map.put(:command, command)
    |> publish()
  end

  def publish("player_queue_changed" = command, message) do
    message
    |> Response.parse_message(pid: :number)
    |> Map.put(:command, command)
    |> publish()
  end

  def publish("player_volume_changed" = command, message) do
    message
    |> Response.parse_message(pid: :number, level: :number, mute: [:on, :off])
    |> Map.put(:command, command)
    |> publish()
  end

  def publish("repeat_mode_changed" = command, message) do
    message
    |> Response.parse_message(pid: :number, repeat: [:all, :one, :off])
    |> Map.put(:command, command)
    |> publish()
  end

  def publish("shuffle_mode_changed" = command, message) do
    message
    |> Response.parse_message(pid: :number, shuffle: [:on, :off])
    |> Map.put(:command, command)
    |> publish()
  end

  def publish("group_volume_changed" = command, message) do
    message
    |> Response.parse_message(pid: :number, level: :number, mute: [:on, :off])
    |> Map.put(:command, command)
    |> publish()
  end

  def publish("user_changed" = command, message) do
    event =
      message
      |> Response.parse_message(un: :string)
      |> Map.put(:command, command)

    message_keys = message |> Response.parse_message() |> Map.keys()

    command =
      cond do
        "signed_in" in message_keys ->
          "user_signed_in"

        "signed_out" in message_keys ->
          "user_signed_out"

        true ->
          raise RuntimeError, message: "user_changed must have signed_in or signed_out."
      end

    publish(%{event | command: command})
  end

  def publish(command, message) do
    require Logger
    Logger.error("Could not publish event: #{command}, #{inspect(message)}")
  end
end
