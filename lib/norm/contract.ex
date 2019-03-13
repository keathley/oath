defmodule Norm.Contracts do
  defmacro __using__(_opts) do
    quote do
      import Norm, only: [post: 1]

      attributes = [
        :pre,
        :post,
      ]
      Module.register_attribute(__MODULE__, :norm_fns, accumulate: true)
      Module.register_attribute(__MODULE__, :pre, accumulate: true)
      Module.register_attribute(__MODULE__, :post, accumulate: true)
      Module.register_attribute(__MODULE__, :post_conditions, accumulate: true)

      @on_definition {Norm, :on_definition}
      @before_compile {Norm, :before_compile}
    end
  end

  def post(f) do
    quote do: f
  end

  # defmacro post(ast) do
  #   quote do
  #     Module.put_attribute(__MODULE__, :post_conditions, unquote(ast))
  #   end
  # end

  def on_definition(%{module: module}, keyword, name, args, guards, body) do
    posts = Module.get_attribute(module, :post)

    unless Enum.empty?(posts) do
      f = %{
        keyword: keyword,
        name: name,
        args: args,
        guards: guards,
        body: body,
        posts: posts
      }
      Module.put_attribute(module, :norm_fns, f)
    end

    Module.delete_attribute(module, :post_conditions)
  end

  defmacro before_compile(env) do
    fns = Module.get_attribute(env.module, :norm_fns)
    Module.delete_attribute(env.module, :norm_fns)

    fns
    |> Enum.reduce({nil, []}, fn(f, acc) -> generate(env, f, acc) end)
    |> elem(1)
    |> Enum.reverse
  end

  def generate(env, f, {prev_fun, all}) do
    IO.inspect(f, label: "Generating")
    override =
      quote do
        defoverridable [{:add, 2}]
      end

    # attrs =
    #   attrs
    #   |> Enum.map(fn {attr, value} ->
    #     {:@, [], [{attr, [], [Macro.escape(value)]}]}
    #   end)

    IO.inspect(f.posts, label: "Posts")

    # post_conditions =
    #   f.posts
    #   |> Enum.map(fn condition -> quote do: condition end)

    # IO.inspect(post_conditions, label: "Conditions")

    body = quote do
      unquote(f.body)
    end

    body = quote do
      result = unquote(body)
      IO.inspect(result, label: "I'm inside the body")
      result
    end

    body = ensure_do(body)

    def_clause = quote do
      Kernel.unquote(f.keyword)(unquote(f.name)(unquote_splicing(f.args)), unquote(body))
    end

    arity = Enum.count(f.args)

    if {f.name, arity} != prev_fun do
      {{f.name, arity}, [def_clause, override] ++ all}
    else
      {{f.name, arity}, [def_clause] ++ all}
    end
  end

  defp ensure_do([{:do, _} | _] = body), do: body
  defp ensure_do(body), do: [do: body]
end

