# Oath

## Names

This project was originally called "Vow", but it looks like someone snagged that on hex. So, I had to change it to Oath.

## Description

Oath provides a system for design by contract in elixir. It uses the excellent,
`:decorator` library by @arjan.

## Usage

You will first need to enable contracts in whichever envs you want to use them.
Typically this will be development and test only.

```elixir
# config/dev.exs
config :oath,
  enable_contracts: true
```

After enabling contracts, you can add `pre` and `post` conditions to your functions.
Preconditions are always run before your function body. Postconditions are run after
your function body executes and will be provided the result from your function
call. You can have any number of pre and post conditions for each function clause.

We'll use an example function with a broken implementation as a demonstration:

```elixir
defmodule Mod do
  use Oath

  @decorate pre("a is an integer", fn(a, _) -> is_integer(a) end)
  @decorate pre("b is an integer", fn(_, b) -> is_integer(b) end)
  @decorate post("the result must be greater then a or b", fn(a, b, result) ->
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
 ** (Oath.ContractError) Mod.add/2 postcondition: 'the result must be greater then a or b' failed with input:
  Arguments:

  a
  => 7

  b
  => 2

  result
  => -5
```

Contract predicates don't have to be pure. Its often useful to use contracts
as a way of validating the functions environment and any of the functions side-effects.

```elixir
@doc """
Stores a name in the database.
"""
@decorate pre("name must be a string", & is_binary(&1))
@decorate pre("name must not be in db", fn name -> !in_database?(name) end)
@decorate post("Name must be normalized in the db", fn name, _result ->
  fetch_from_db(name) == String.capitalize(name)
end)
def store_in_db(name) do
  #...
end
```

## When to enable contracts?

Classically, you should only enable contracts in dev and test modes. You want
to avoid enabling contracts in production as this will lower your production
performance due to additional checking. It also means that you won't be able
to write side-effecting contracts, which you'll want to be able to do in testing
modes.

By default, contracts are disabled and will be compiled away so you won't need
to do anything for production builds.

## Installation

```elixir
def deps do
  [
    {:oath, "~> 0.1.0"},
  ]
end
```
