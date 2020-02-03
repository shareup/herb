defmodule HerbTest do
  use ExUnit.Case
  doctest Herb

  test "has a main" do
    assert function_exported?(Herb, :main, 1)
  end
end
