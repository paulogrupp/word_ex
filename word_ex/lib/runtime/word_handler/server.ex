defmodule WordEx.Runtime.WordHandler.Server do
  @type t :: pid()
  @me __MODULE__

  use Agent

  alias WordEx.Impl.WordHandler

  def start_link(_) do
    Agent.start_link(&WordHandler.word_list_hash/0, name: @me)
  end

  def word_exists?(word) do
    Agent.get(@me, fn word_list_hash -> WordHandler.word_exists?(word_list_hash, word) end)
  end
end
