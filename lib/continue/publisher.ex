defmodule Continue.Publisher do
  alias Phoenix.PubSub

  defstruct topic: nil

  def new(topic) do
    %Continue.Publisher{topic: topic}
  end

  def id() do
    :crypto.strong_rand_bytes(16) |> Base.encode16()
  end

  def broadcast(topic, text) do
     PubSub.broadcast(
       Continue.PubSub,
       topic,
       {:publisher, Continue.Publisher.id(), text}
     )
  end

  defimpl Collectable, for: Continue.Publisher do
    def into(%{topic: topic} = publisher) do
      {:ok,
       fn
         :ok, {:cont, text} ->
           Continue.Publisher.broadcast(topic, text)

         :ok, _ ->
           publisher
       end}
    end
  end
end
