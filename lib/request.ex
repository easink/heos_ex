defmodule Heos.Request do
  @moduledoc """
  Heos Request
  """

  # @alias Heos.Request
  defstruct command: nil, args: %{}

  # @spec new(command :: String.t(), args :: map) :: list(String.t())
  def new(command, args) do
    # %{command: command, args: args}
    %Heos.Request{command: command, args: args}
  end

  # @spec generate(%Request{}) :: iolist()
  # @spec generate(map) :: iolist()
  def generate(%__MODULE__{} = req) do
    message = ["heos://", req.command]
    nl = ["\r\n"]

    if req.args == %{},
      do: message ++ nl,
      else: message ++ ["?", URI.encode_query(req.args)] ++ nl
  end

  #
  # Private
  #

  # defp sanitize(string) do
  #   string
  #   |> String.replace("&", "%26")
  #   |> String.replace("=", "%3D")
  #   |> String.replace("%", "%25")
  # end
end
