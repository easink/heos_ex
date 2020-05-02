defmodule Heos.Discover do
  @moduledoc """
  Discover Heos Devices.
  """

  # use Task

  alias Nerves.SSDPClient

  # require Logger

  @ssdp_target "urn:schemas-denon-com:device:ACT-Denon:1"

  # @discover_interval 5 * 60_000
  # @discover_interval :timer.minutes(5)

  # def start_link(_args \\ []) do
  #   Task.start_link(__MODULE__, :discover, [])
  # end

  #
  # Tasks
  #

  @spec discover() :: {:ok, String.t()} | {:error, :no_heos_devices_found}
  def discover do
    devices = SSDPClient.discover(target: @ssdp_target)

    # Logger.debug(fn -> "Devices found: #{inspect(devices, pretty: true)}" end)
    # hosts = for {_, dev} <- devices, dev[:host], do: dev[:host]

    case Map.to_list(devices) do
      [{_, %{host: host}} | _] ->
        {:ok, host}

      _ ->
        {:error, :no_heos_devices_found}
    end
  end
end
