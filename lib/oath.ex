defmodule Oath do
  @moduledoc """
  Oath provides a system for utilizing design by contract in elixir.

  ## Pre and Post conditions

  You can decorate any of your functions with preconditions and postconditions.

  ```elixir
  @decorator pre("inputs are ints", & is_integer(&1) && is_integer(&2))
  @decorate post("the result must be greater than a or b", fn a, b, result ->
    result >= a && result >= b
  end)
  def add(a, b) do
    a + b
  end
  ```

  If your callers provide incorrect data or your function returns incorrect repsonses, an exception will be thrown.
  """
  use Decorator.Define, [pre: 2, post: 2]

  def pre(text, condition, body, context) do
    arg_names = Enum.map(context.args, fn {name, _, _} -> name end)
    fn_name = fn_name(context)

    if enabled?() do
      quote do
        contract = Oath.Contract.new(
          :pre,
          unquote(text),
          unquote(condition),
          unquote(context.args),
          unquote(arg_names),
          unquote(fn_name)
        )

        Oath.Contract.validate(contract)

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

        contract = Oath.Contract.new(
          :post,
          unquote(text),
          unquote(condition),
          unquote(context.args) ++ [result],
          unquote(arg_names),
          unquote(fn_name)
        )

        Oath.Contract.validate(contract)

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
    Application.get_env(:oath, :enable_contracts, false)
  end
end

