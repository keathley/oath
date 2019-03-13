defmodule NormTest do
  use ExUnit.Case

  # alias Norm.ContractError

  defmodule Mod do
    use Norm

    @norm pre("i is an integer", fn(i, _) -> is_integer(i) end)
    @norm pre("j is an integer", fn(_, j) -> is_integer(j) end)
    @norm post("the result must be greater then i or j",
               fn(i, j, result) -> result > i && result > j end)
    def add(i, j) do
      if i == 7 do
        i - 7 + j
      else
        i + j
      end
    end
  end

  test "norm can specify post conditions" do
    assert Mod.add(1, 2) == 3
    assert_raise Norm.ContractError, fn ->
      Mod.add(7, 3)
    end
    assert_raise Norm.ContractError, fn ->
      Mod.add("foo", 3)
    end
    assert_raise Norm.ContractError, fn ->
      Mod.add(3, "foo")
    end
  end
end
