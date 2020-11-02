defmodule Vow do
  @moduledoc """
  """
  use Decorator.Define, [pre: 2, post: 2]

  def pre(text, condition, body, context) do
    arg_names = Enum.map(context.args, fn {name, _, _} -> name end)
    fn_name = fn_name(context)

    if enabled?() do
      quote do
        contract = Vow.Contract.new(
          :pre,
          unquote(text),
          unquote(condition),
          unquote(context.args),
          unquote(arg_names),
          unquote(fn_name)
        )

        Vow.Contract.validate(contract)

        unquote(body)
      end
    else
      quote do
        unquote(body)
      end
    end
  end

  def post(text, condition, body, context) do
    arg_names = Enum.map(context.args, fn {name, _, _} -> name end) ++ [:result]
    fn_name = fn_name(context)

    if enabled?() do
      quote do
        result = unquote(body)

        contract = Vow.Contract.new(
          :post,
          unquote(text),
          unquote(condition),
          unquote(context.args) ++ [result],
          unquote(arg_names),
          unquote(fn_name)
        )

        Vow.Contract.validate(contract)

        result
      end
    else
      quote do
        unquote(body)
      end
    end
  end

  @doc false
  def fn_name(context) do
    "#{context.module}.#{context.name}/#{context.arity}"
  end

  defp enabled? do
    Application.get_env(:vow, :enable_contracts, false)
  end
end

