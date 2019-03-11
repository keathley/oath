defmodule Norm do
  defmacro __using__(_opts) do
    quote do
      attributes = [
        :pre,
        :post,
      ]

      Enum.each(attributes, &Module.register_attribute(__MODULE__, &1, accumulate: true))

      # @after_compile Norm
      @after_compile Norm
    end
  end

  defmacro __before_compile__(_) do
    quote do
    end
  end

  def __after_compile__(%{module: module}, _) do
    IO.inspect(module, label: "Environment")

    Module.get_attribute(module, :post)
    |> IO.inspect(label: "Post conditions")
  end
end

