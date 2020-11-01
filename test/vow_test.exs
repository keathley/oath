defmodule VowTest do
  use ExUnit.Case

  defmodule Mod do
    use Vow

    @decorate pre("i is an integer", fn(i, _) -> is_integer(i) end)
    @decorate pre("j is an integer", fn(_, j) -> is_integer(j) end)
    @decorate post("the result must be greater then i or j",
               fn(i, j, result) -> result > i && result > j end)
    def add(i, j) do
      if i == 7 do
        i - 7 + j
      else
        i + j
      end
    end

    @decorate pre("precondition", fn -> :foo end)
    def invalid_pre do
      nil
    end

    @decorate post("post", fn _result -> :foo end)
    def invalid_post do
      nil
    end
  end

  test "vow can specify pre and post conditions" do
    assert Mod.add(1, 2) == 3
    assert_raise Vow.ContractError, fn ->
      Mod.add(7, 3)
    end
    assert_raise Vow.ContractError, fn ->
      Mod.add("foo", 3)
    end
    assert_raise Vow.ContractError, fn ->
      Mod.add(3, "foo")
    end
  end

  test "vow ensures that pre and post conditions return boolean values" do
    assert_raise Vow.InvalidContractError, fn ->
      Mod.invalid_pre()
    end
    assert_raise Vow.InvalidContractError, fn ->
      Mod.invalid_post()
    end
  end
end
