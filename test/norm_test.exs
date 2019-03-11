defmodule NormTest do
  use ExUnit.Case

  defmodule Mod do
    use Norm

    @post fn([i, j], result) -> result > i && result > j end
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
    assert_raise RuntimeException, fn ->
      Mod.add(7, 3)
    end
  end
end
