defmodule Continue.Publisher do
  alias Phoenix.PubSub

  defstruct topic: nil

  def new(topic) do
    %Continue.Publisher{topic: topic}
  end

  defimpl Collectable, for: Continue.Publisher do
    def into(%{topic: topic} = publisher) do
      {:ok,
       fn
         :ok, {:cont, message} ->
           PubSub.broadcast(Continue.PubSub, topic, {:publisher, message})

         :ok, _ ->
           publisher
       end}
    end
  end
end
