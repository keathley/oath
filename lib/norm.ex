defmodule Norm do
  use Decorator.Define, [post: 2, pre: 2]

  defmodule ContractError do
    defexception [:message]

    def exception(contract) do
      %__MODULE__{message: Norm.Contract.explain(contract)}
    end
  end

  defmodule InvalidContractError do
    defexception [:message]

    def exception(_value) do
      msg = "Contracts must return a boolean value"
      %__MODULE__{message: msg}
    end
  end

  defmodule Contract do
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

    def validate(contract) do
      case apply(contract.condition, contract.args) do
        true ->
          true

        false ->
          raise ContractError, contract

        _ ->
          raise InvalidContractError
      end
    end
  end

  def pre(text, condition, body, context) do
    arg_names = Enum.map(context.args, fn {name, _, _} -> name end)
    fn_name = "#{context.module}.#{context.name}/#{context.arity}"

    quote do
      contract = Contract.new(
        :pre,
        unquote(text),
        unquote(condition),
        unquote(context.args),
        unquote(arg_names),
        unquote(fn_name)
      )

      Contract.validate(contract)

      unquote(body)
    end
  end

  def post(text, condition, body, context) do
    arg_names = Enum.map(context.args, fn {name, _, _} -> name end) ++ [:result]
    fn_name = fn_name(context)

    quote do
      result = unquote(body)

      contract = Contract.new(
        :pre,
        unquote(text),
        unquote(condition),
        unquote(context.args) ++ [result],
        unquote(arg_names),
        unquote(fn_name)
      )

      Contract.validate(contract)

      result
    end
  end

  def fn_name(context) do
    "#{context.module}.#{context.name}/#{context.arity}"
  end
end

