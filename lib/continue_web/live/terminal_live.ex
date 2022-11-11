defmodule ContinueWeb.TerminalLive do
  use Phoenix.LiveView

  alias Phoenix.PubSub

  def mount(_params, _session, socket) do
    PubSub.subscribe(Continue.PubSub, "terminal")
    socket = assign(socket, :messages, [])
    {:ok, socket, temporary_assigns: [messages: []]}
  end

  def handle_info({:publisher, id, text}, socket) do
    socket = assign(socket, :messages, [%{id: id, text: text}])
    {:noreply, socket}
  end
end
