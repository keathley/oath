defmodule Oath.Contract do
  @moduledoc false

  def new(type, description, condition, args, arg_names, fn_name) do
    %{
      type: type,
      description: description,
      condition: condition,
      args: args,
      arg_names: arg_names,
      fn_name: fn_name,
    }
  end

  def explain(contract) do
    type = case contract.type do
      :pre -> "precondition"
      :post -> "postcondition"
    end

    desc = contract.description

    full_name =
      contract.fn_name
      |> String.replace("Elixir.", "")

    args =
      contract.args
      |> Enum.zip(contract.arg_names)
      |> Enum.map(fn {arg, name} -> "\t#{name}\n\t=> #{arg}" end)
      |> Enum.join("\n\n")

    """
    #{full_name} #{type}: '#{desc}' failed with input:
    \tArguments:

    #{args}
    """
  end

  @doc false
  def validate(contract) do
    case apply(contract.condition, contract.args) do
      true ->
        true

      false ->
        raise Oath.ContractError, explain(contract)

      _ ->
        raise Oath.InvalidContractError
    end
  end
end
