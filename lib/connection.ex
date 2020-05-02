defmodule Heos.Connection do
  @moduledoc """
  Handling connection to a Heos device
  """
  @behaviour :gen_statem

  @transport Application.get_env(:heos, :transport, Heos.Transport.TCP)
  @type conn :: pid() | atom

  alias Heos.{Response, Request, Events}

  require Logger

  # @type socket :: :inet.socket()

  # @type host_address :: :inet.socket_address() | :inet.hostname()
  # @type host_port :: :inet.port_number()

  @port 1255

  # @connect_timeout 5_000

  ############################################################################
  #
  #  Setup
  #

  def start_link(opts) when is_list(opts) do
    case Keyword.fetch(opts, :name) do
      :error ->
        :gen_statem.start_link(__MODULE__, opts, [])

      {:ok, atom} when is_atom(atom) ->
        :gen_statem.start_link({:local, atom}, __MODULE__, opts, [])

      {:ok, {:global, _term} = tuple} ->
        :gen_statem.start_link(tuple, __MODULE__, opts, [])

      {:ok, {:via, via_module, _term} = tuple} when is_atom(via_module) ->
        :gen_statem.start_link(tuple, __MODULE__, opts, [])

      {:ok, other} ->
        raise ArgumentError, """
        expected :name option to be one of the following:
          * nil
          * atom
          * {:global, term}
          * {:via, module, term}
        Got: #{inspect(other)}
        """
    end
  end

  def stop(conn, timeout \\ 30_000) do
    :gen_statem.stop(conn, :normal, timeout)
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 5000
    }
  end

  @impl true
  def callback_mode(), do: :state_functions

  # def callback_mode(), do: [:state_functions, :state_enter]

  ############################################################################
  #
  #  API
  #

  @doc """
  connect()
  """
  @spec connect(conn) :: :ok | {:error, :connecting}
  def connect(conn) do
    :gen_statem.call(conn, :connect)
  end

  @doc """
  disconnect()
  """
  @spec disconnect(conn) :: :ok
  def disconnect(conn) do
    :gen_statem.call(conn, :disconnect)
  end

  @doc """
  send_command(command)
  """
  # @spec request(command :: %Request{}) :: {:ok, %Response{}} | {:error, term}
  def request(conn, %Request{} = req) do
    :gen_statem.call(conn, {:request, req})
  end

  # @spec subscribe(conn) :: :ok
  # def subscribe(conn) do
  #   GenServer.call(conn, :subscribe)
  # end

  ############################################################################
  #
  #  Callbacks
  #

  # def handle_call({:subscribe, conn}, _from, state) do
  #   {:reply, :ok, %{data | pid: pid}}
  # end

  @impl true
  def init(opts) do
    host = Keyword.get(opts, :host, nil)

    host =
      cond do
        is_binary(host) -> String.to_charlist(host)
        is_list(host) -> host
        true -> nil
      end

    port = Keyword.get(opts, :port, @port)

    Process.flag(:trap_exit, true)

    {:ok, :disconnected,
     %{
       host: host,
       port: port,
       socket: nil,
       request_from: nil,
       command_in_flight: nil
     }}
  end

  @impl true
  def terminate(reason, state, data) do
    Logger.debug(fn ->
      "TERMINATE: #{inspect({reason, state, data})}"
    end)

    :ok
  end

  def disconnected({:call, from}, :connect, data) do
    host = data.host
    port = data.port

    Logger.debug(fn -> "[I] Connecting to #{host}:#{port}" end)

    case @transport.connect(host, port, [:binary, active: true, packet: :line]) do
      {:ok, socket} ->
        Logger.debug(fn -> "[I] Connected to #{host}:#{port}" end)

        :gen_statem.reply(from, :ok)
        {:next_state, :connected, %{data | socket: socket}}

      # {:state_timeout, @connect_timeout, :disconnecting}}

      {:error, reason} ->
        # send(self(), :discover)
        Logger.error(fn -> "[E]: Connecting, #{inspect(reason)}" end)
        :gen_statem.reply(from, {:error, :connecting})
        :keep_state_and_data
    end
  end

  def disconnected({:call, from}, :disconnect, _data) do
    Logger.warn("Already disconnectd.")
    :gen_statem.reply(from, :ok)
    :keep_state_and_data
  end

  # def setup(:enter, _, data) do
  #   Command.system_register_for_change_events()
  #   Command.system_prettify_json_response("off")
  #   Command.player_get_players()
  #   {:next_state, :connected, data}
  # end

  def connected({:call, from}, {:request, %Request{} = request}, data) do
    Logger.debug(fn -> "Send request (#{inspect(request)})" end)
    Logger.debug(fn -> "Send state   (#{inspect(data)})" end)

    # :dbg.tracer()
    # :dbg.p(self(), [:all])

    :ok = @transport.send_request(data.socket, request)

    {:keep_state, %{data | request_from: from, command_in_flight: request.command}}
  end

  def connected({:call, from}, :disconnect, data) do
    Logger.debug("disconnecting... FIX DISCONNECT")
    :gen_statem.reply(from, :ok)
    {:next_state, :disconnect, data}
  end

  # @impl true
  # def handle_info(:discover, data) do
  #   host = Discover.discover()

  #   updated_conn = %{data.conn | host: host, port: @port}
  #   send(self(), :connect)

  #   # report discoved hosts
  #   # send(Heos.Manager, {:connect, hosts})
  #   {:noreply, %{data | conn: updated_conn}}
  # end

  # @impl true

  def connected(:info, {:tcp, _, tcp_data}, data) do
    Logger.debug(fn -> "TCP: #{inspect(tcp_data)}" end)
    command_in_flight = data.command_in_flight

    case Response.parse(tcp_data) do
      {:ok, %Response{command: ^command_in_flight, message: "command under process"} = response} ->
        Logger.debug(fn -> "RESPONSE, #{inspect(response)}, command under process..." end)
        :keep_state_and_data

      {:ok, %Response{command: ^command_in_flight} = response} ->
        Logger.debug(fn -> "RESPONSE: #{inspect(response)}" end)
        :gen_statem.reply(data.request_from, {:ok, response})
        {:keep_state, %{data | request_from: nil, command_in_flight: nil}}

      {:ok, %Response{command: command, message: message} = response} ->
        Logger.debug(fn -> "RESPONSE, #{inspect(response)}, NOT IN FLIGHT, still waiting..." end)

        if String.starts_with?(command, "event/") do
          Events.publish(command, message)
          # Logger.info("EVENT #{command}, will notify subscribers")
        end

        # :gen_statem.reply(data.request_from, {:error, :not_command_in_flight})
        :keep_state_and_data

      {:error, reason} ->
        Logger.error(fn -> "#{inspect(reason)}" end)
        :gen_statem.reply(data.request_from, {:error, reason})
        {:keep_state, %{data | request_from: nil, command_in_flight: nil}}
    end
  end

  # @impl true
  def connected(:info, {:tcp_closed, _}, data) do
    Logger.debug(fn -> " Close connection." end)
    # Process.send_after(self(), :connect, 1000)
    updated_conn = %{data.conn | socket: nil}
    # {:noreply, %{data | conn: updated_conn}}
    {:next_state, :disconnected, %{data | conn: updated_conn}}
  end

  # @impl true
  def connected(type, event, data) do
    Logger.debug(fn -> "[I] UNKNOWN: #{inspect(binding())}" end)
    :keep_state_and_data
  end
end
