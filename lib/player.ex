defmodule Heos.Player do
  @moduledoc """
  Heos device
  """

  defstruct pid: 0,
            ip: "",
            lineout: 0,
            name: "",
            model: "",
            network: "",
            version: ""

  @type t :: %__MODULE__{
          pid: number,
          ip: String.t(),
          lineout: non_neg_integer,
          name: String.t(),
          model: String.t(),
          network: String.t(),
          version: String.t()
        }
end
