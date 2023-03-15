defmodule WordExTest do
  use ExUnit.Case
  doctest WordEx

  test "greets the world" do
    assert WordEx.hello() == :world
  end
end
