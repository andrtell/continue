defmodule ContinueWeb.TerminalLive do
  use Phoenix.LiveView

  alias Continue.Terminal

  def mount(_params, _session, socket) do
    Terminal.subscribe()
    socket = assign(socket, :messages, [])
    {:ok, socket, temporary_assigns: [messages: []]}
  end

  def handle_info({:terminal, id, text}, socket) do
    socket = assign(socket, :messages, [%{id: id, text: text}])
    {:noreply, socket}
  end
end
