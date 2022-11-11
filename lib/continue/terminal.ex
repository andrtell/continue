defmodule Continue.Terminal do
  @topic "terminal"

  alias __MODULE__

  alias Phoenix.PubSub

  defstruct []

  def new() do
    %Terminal{}
  end

  def line_id() do
    :crypto.strong_rand_bytes(16) |> Base.encode16()
  end

  def broadcast(text) do
    PubSub.broadcast(
      Continue.PubSub,
      @topic,
      {:terminal, Terminal.line_id(), text}
    )
  end

  def subscribe() do
    PubSub.subscribe(Continue.PubSub, @topic)
  end

  defimpl Collectable, for: Continue.Terminal do
    def into(%{} = terminal) do
      {:ok,
       fn
         :ok, {:cont, text} ->
           Continue.Terminal.broadcast(text)

         :ok, _ ->
           terminal
       end}
    end
  end
end
