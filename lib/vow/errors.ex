defmodule Vow.ContractError do
  @moduledoc false
  defexception [:message]

  def exception(message) do
    %__MODULE__{message: message}
  end
end

defmodule Vow.InvalidContractError do
  @moduledoc false
  defexception [:message]

  def exception(_value) do
    msg = "Contracts must return a boolean value"
    %__MODULE__{message: msg}
  end
end

