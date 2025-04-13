defmodule KojimaBotTest do
  use ExUnit.Case
  doctest KojimaBot

  test "greets the world" do
    assert KojimaBot.hello() == :world
  end
end
