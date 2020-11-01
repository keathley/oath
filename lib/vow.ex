defmodule Vow do
  @moduledoc """
  """
  use Decorator.Define, [pre: 2, post: 2]

  def pre(text, condition, body, context) do
    arg_names = Enum.map(context.args, fn {name, _, _} -> name end)
    fn_name = fn_name(context)

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
  end

  def post(text, condition, body, context) do
    arg_names = Enum.map(context.args, fn {name, _, _} -> name end) ++ [:result]
    fn_name = fn_name(context)

    quote do
      result = unquote(body)

      contract = Vow.Contract.new(
        :pre,
        unquote(text),
        unquote(condition),
        unquote(context.args) ++ [result],
        unquote(arg_names),
        unquote(fn_name)
      )

      Vow.Contract.validate(contract)

      result
    end
  end

  @doc false
  def fn_name(context) do
    "#{context.module}.#{context.name}/#{context.arity}"
  end
end

