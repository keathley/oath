# Vow

Vow provides a system for design by contract in elixir. It uses the excellent,
`:decorator` library by @arjan.

## Usage

You will first need to enable contracts in whichever envs you want to use them.
Typically this will be development and test only.

```elixir
# config/dev.exs
config :vow,
  enable_contracts: true
```

After enabling contracts, you can add `pre` and `post` conditions to your functions.
Preconditions are always run before your function body. Postconditions are run after
your function body executes and will be provided the result from your function
call.

We'll use an example function with a broken implementation as a demonstration:

```elixir
defmodule Mod do
  use Vow

  @decorate pre("inputs are ints", & is_integer(&1) && is_integer(&2))
  @decorate post("the result must be greater than a or b", fn a, b, result ->
    result >= a && result >= b
  end)
  def add(a, b) do
    if a == 7 do
      (a * -1) + b
    else
      a + b
    end
  end
end
```

Calling this function with contracts enabled will cause an exception to be raised.

```elixir
Mod.add(7, 2)
 ** (Vow.ContractError) Mod.add/2 precondition: 'the result must be greater then a or b' failed with input:
  Arguments:

  a
  => 7

  b
  => 2

  result
  => -5
```

## Installation

```elixir
def deps do
  [
    {:vow, "~> 0.1.0"},
  ]
end
```
