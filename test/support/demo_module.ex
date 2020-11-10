defmodule Oath.DemoModule do
  use Oath

  @decorate pre("i is an integer", fn(i, _) -> is_integer(i) end)
  @decorate pre("j is an integer", fn(_, j) -> is_integer(j) end)
  @decorate post("the result must be greater then i or j", fn(i, j, result) ->
    result > i && result > j
  end)
  @doc """
  Adds 2 numbers together.
  """
  def add(i, j) do
    if i == 7 do
      i - 7 + j
    else
      i + j
    end
  end

  @doc """
  Stores a name in the database.
  """
  @decorate pre("name must not be in db", fn name -> !in_database?(name) end)
  @decorate post("Name must be normalized in the db", fn name, _result ->
    fetch_from_db(name) == String.capitalize(name)
  end)
  def store_in_db(name) do
    # ...
  end

  defp in_database?(_) do
    false
  end

  defp fetch_from_db(n) do
    String.capitalize(n)
  end
end

