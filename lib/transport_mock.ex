defmodule Heos.Transport.API do
  @moduledoc false

  @type error_connect_reason :: :timeout | :inet.posix()
  @type error_send_reason :: :closed | :inet.posix()
  @type socket_address :: :inet.socket_address() | :inet.hostname()
  # @type socket_type :: :socket.socket()
  @type socket_type :: term
  @type port_number :: :inet.port_number()

  @callback connect(
              address :: socket_address,
              port :: port_number,
              options :: list()
            ) :: {:ok, socket_type()} | {:error, term}

  @callback send_request(
              socket :: socket_type(),
              request :: %Heos.Request{}
            ) :: :ok | {:error, term}
end

defmodule Heos.Transport.TCP do
  @moduledoc false
  @behaviour Heos.Transport.API

  alias Heos.Request

  @impl true
  def connect(address, port, options) do
    :gen_tcp.connect(address, port, options)
  end

  @impl true
  def send_request(socket, request) do
    req = Request.generate(request)
    :gen_tcp.send(socket, req)
  end
end

defmodule Heos.Transport.Mock do
  @moduledoc false
  @behaviour Heos.Transport.API

  alias Heos.Request
  require Logger

  @player_1 %{
    name: "player name 1",
    pid: 1,
    gid: "group id",
    model: "player model 1",
    version: "player version 1",
    network: "wired",
    lineout: 0,
    control: "control option",
    serial: "serial number"
  }
  @player_2 %{
    name: "player name 2",
    pid: 2,
    gid: "group id",
    model: "player model 2",
    version: "player version 2",
    network: "wired",
    lineout: 0,
    control: "control option",
    serial: "serial number"
  }

  @impl true
  def connect(_address, _port, _options) do
    :socket.open(:inet, :stream)
  end

  @impl true
  def send_request(
        _socket,
        %Request{command: "system/register_for_change_events", args: %{enable: :on}}
      ) do
    reply(%{
      heos: %{
        command: "system/register_for_change_events",
        result: "success",
        message: "enable=on"
      }
    })
  end

  def send_request(
        _socket,
        %Request{command: "system/register_for_change_events", args: %{enable: :off}}
      ) do
    reply(%{
      heos: %{
        command: "system/register_for_change_events",
        result: "success",
        message: "enable=off"
      }
    })
  end

  def send_request(_socket, %Request{command: "system/register_for_change_events"}) do
    reply(%{
      heos: %{
        command: "system/register_for_change_events",
        result: "success",
        message: "enable=off"
      }
    })
  end

  def send_request(_socket, %Request{command: "system/heart_beat"}) do
    reply(%{heos: %{command: "system/heart_beat", result: "success", message: ""}})
  end

  def send_request(_socket, %Request{command: "system/reboot"}) do
    reply(%{heos: %{command: "system/reboot", result: "success", message: ""}})
  end

  def send_request(_socket, %Request{command: "system/prettify_json_response"}) do
    reply(%{
      heos: %{command: "system/prettify_json_response", result: "success", message: "enable=off"}
    })
  end

  # player

  def send_request(_socket, %Request{command: "player/get_players"}) do
    pid = 1

    reply(%{
      heos: %{command: "player/get_players", result: "success", message: "pid=#{pid}"},
      payload: [@player_1, @player_2]
    })
  end

  def send_request(_socket, %Request{command: "player/get_player_info", args: %{pid: pid}}) do
    reply(%{
      heos: %{command: "player/get_player_info", result: "success", message: "pid=#{pid}"},
      payload: @player_1
    })
  end

  def send_request(_socket, %Request{command: "player/get_play_state", args: %{pid: pid}}) do
    reply(%{
      heos: %{
        command: "player/get_play_state",
        result: "success",
        message: "pid=#{pid}&state=stop"
      }
    })
  end

  def send_request(_socket, %Request{
        command: "player/set_play_state",
        args: %{pid: pid, state: state}
      }) do
    reply(%{
      heos: %{
        command: "player/set_play_state",
        result: "success",
        message: "pid=#{pid}&state=#{state}"
      }
    })
  end

  def send_request(_socket, %Request{command: "player/get_now_playing_media", args: %{pid: pid}}) do
    reply(%{
      heos: %{command: "player/get_now_playing_media", result: "success", message: "pid=#{pid}"},
      payload: %{
        type: "song",
        song: "song name",
        album: "album name",
        artist: "artist name",
        image_url: "image url",
        mid: "media id",
        qid: "queue id",
        sid: "source_id",
        album_id: "Album Id"
      }
    })
  end

  def send_request(_socket, %Request{command: "player/get_volume", args: %{pid: pid}}) do
    reply(%{
      heos: %{command: "player/get_volume", result: "success", message: "pid=#{pid}&level=50"}
    })
  end

  def send_request(_socket, %Request{
        command: "player/set_volume",
        args: %{pid: pid, level: level}
      }) do
    reply(%{
      heos: %{
        command: "player/set_volume",
        result: "success",
        message: "pid=#{pid}&level=#{level}"
      }
    })
  end

  def send_request(_socket, %Request{command: command} = req) do
    Logger.warn(fn -> "NO VALID SEND_REQUEST: #{inspect(req)}" end)

    reply(%{
      heos: %{
        command: command,
        result: "fail",
        message: "eid=1&text=error text&command_arguments"
      }
    })
  end

  defp reply(response) do
    response = {:tcp, :ignored_socket, Jason.encode!(response)}
    send(self(), response)
    :ok
  end
end
