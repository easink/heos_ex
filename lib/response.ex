defmodule Heos.Response do
  @moduledoc """
  Heos.Response handles messages... =)
  """
  require Logger

  defstruct [:command, :message, :payload]

  @doc """
  parse(data)
  """
  @spec parse(String.t()) :: {:ok, %Heos.Response{}} | {:error, term}
  def parse(data) do
    data
    |> Jason.decode!()
    |> parse_reply()
  end

  @doc """
  Parse message field.

  Returns `{:ok, valid_map}`.

  ## Examples

      iex> Heos.Response.parse_message("pid=1&state=play")
      {:ok, %{"pid" => "1", "state" => "play"}}

  """
  @spec parse_message(String.t()) :: map
  def parse_message(message) do
    URI.decode_query(message)
  end

  @doc """
  Parse message field, with acceptable attributes.

  Returns `{:ok, valid_map}`.

  ## Examples

      iex> Heos.Response.parse_message("pid=1&state=play", state: [:play, :pause, :stop]))
      {:ok, %{state: :play}}

      iex> Heos.Response.parse_message("pid=1&state=play", pid: :number))
      {:ok, %{pid: 1}}

  """
  @spec parse_message(String.t(), Keyword.t()) :: map
  def parse_message(message, attr) do
    # accept_keys = Keyword.keys(attrs)
    decoded_message = URI.decode_query(message)

    Enum.reduce(attr, %{}, fn {key, type}, acc ->
      case Map.get(decoded_message, Atom.to_string(key)) do
        nil -> acc
        value -> maybe_add_valid_value(acc, key, type, value)
      end
    end)
  end

  # def parse_payload(payload) do
  #   payload
  # end

  #
  # Private
  #

  @spec parse_reply(map) :: {:ok, %Heos.Response{}} | {:error, term}
  defp parse_reply(%{"heos" => %{"command" => command, "message" => message, "result" => "fail"}}) do
    parsed_message = parse_message(message)
    Logger.error("#{command} failed, #{inspect(parsed_message)}.")

    {:error, parsed_message["text"]}
  end

  defp parse_reply(%{"heos" => %{"command" => command, "message" => message}} = reply) do
    payload = Map.get(reply, "payload", %{})

    Logger.debug(fn -> "#{inspect(command)}, #{inspect(message)}, #{inspect(payload)}" end)
    # parse(command, message, payload)
    response =
      %Heos.Response{command: command}
      |> add_message(message)
      |> add_payload(payload)

    {:ok, response}
  end

  defp parse_reply(reply) do
    Logger.error("No parser for message #{inspect(reply)}.")
    {:error, :could_not_parse}
  end

  defp add_message(response, message) do
    %Heos.Response{response | message: message}
  end

  defp add_payload(response, payload) do
    %Heos.Response{response | payload: payload}
  end

  @spec maybe_add_valid_value(map, atom, Keyword.t(), atom) :: map
  defp maybe_add_valid_value(acc, key, type, value) do
    val = get_valid_attr(type, value)

    if val,
      do: Map.put(acc, key, val),
      else: acc
  end

  @spec get_valid_attr(Keyword.t(), atom) :: atom | nil
  defp get_valid_attr(type, value) when is_list(type) do
    Enum.find(type, fn val ->
      if Atom.to_string(val) == value, do: val, else: nil
    end)
  end

  defp get_valid_attr(:number, value) do
    # should us try / rescue ?
    String.to_integer(value)
  end

  defp get_valid_attr(:string, value) do
    value
  end

  defp get_valid_attr(:any, value) do
    value
  end
end
