defmodule Continue.Runner do
  use GenServer

  # API 

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg, name: Continue.Runner)
  end

  def run(m, f, args) do
    GenServer.cast(Continue.Runner, {:run, {m, f, args}})
  end

  # OTP

  @impl true
  def init(_args) do
    {:ok, []}
  end

  @impl true
  def handle_cast({:run, {m, f, args}}, state) do
    apply(m, f, args)
    {:noreply, state}
  end
end
