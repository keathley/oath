defmodule Norm.DemoModule do
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

  # @norm pre("name must not be in db", fn name -> ! in_database?(name) end)
  # @norm post("Name must be normalized in the db",
  #   fn name, _result -> fetch_from_db(name) == String.capitalize(name) end)
  # def store_in_db(name) do
  #   # ...
  # end
end

