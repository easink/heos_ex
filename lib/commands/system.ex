defmodule Heos.Commands.System do
  @moduledoc false

  ## # API
  ## #

  @type conn :: pid() | atom

  alias Heos.{Command, Response}

  #########
  @command "system/register_for_change_events"
  @doc """
  By default HEOS speaker does not send Change events.
  Controller needs to send this command with enable=on
  when it is ready to receive unsolicit responses from CLI.
  Please refer to "Driver Initialization" section regarding
  when to register for change events.

  Command: Heos.Commands.System(pid, :on | :off)
  """
  @spec register_for_change_events(conn, :on | :off) :: {:ok, :on | :off} | {:error, term}
  def register_for_change_events(conn, enable \\ :on) do
    enable = if enable == :on, do: :on, else: :off

    with {:ok, response} <- Command.request(conn, @command, %{enable: enable}) do
      enable =
        response.message
        |> Response.parse_message(enable: [:on, :off])
        |> Map.get(:enable)

      {:ok, enable}
    end
  end

  #########
  @command "system/check_account"

  def check_account(_conn) do
    {:error, :not_implemented}
  end

  #########
  @command "system/sign_in"

  def sign_in(_conn) do
    {:error, :not_implemented}
  end

  #########
  @command "system/sign_out"

  def sign_out(_conn) do
    {:error, :not_implemented}
  end

  #########
  @command "system/heart_beat"

  @spec heart_beat(conn) :: :ok | {:error, term}
  def heart_beat(conn) do
    with {:ok, _response} <- Command.request(conn, @command), do: :ok
  end

  #########
  @command "system/reboot"
  @doc """
  Using this command controllers can reboot HEOS device.  This command can
  only be used to reboot the HEOS device to which the controller is
  connected through CLI port.
  """
  @spec reboot(conn) :: :ok | {:error, term}
  def reboot(conn) do
    with {:ok, _response} <- Command.request(conn, @command), do: :ok
  end

  #########
  @command "system/prettify_json_response"

  @spec prettify_json_response(conn, :on | :off) :: {:ok, :off} | {:error, :only_off_supported}
  def prettify_json_response(conn, enable \\ :off) do
    case enable do
      :off ->
        with {:ok, _response} <- Command.request(conn, @command, %{enable: :off}),
             do: {:ok, :off}

      _ ->
        {:error, :only_off_supported}
    end
  end
end
