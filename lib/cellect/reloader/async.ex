defmodule Cellect.Reloader.Async do
  use GenServer

  @behaviour Cellect.Reloader

  def start_link do
    GenServer.start_link __MODULE__, {}, name: __MODULE__
  end

  def reload_subject_set({workflow_id, subject_set_id}) do
    GenServer.cast(__MODULE__, {:reload_subject_set, workflow_id, subject_set_id})
  end

  # Server (callbacks)

  def handle_cast({:reload_subject_set, workflow_id, subject_set_id}, state) do
    subject_ids = Cellect.Workflow.subject_ids(workflow_id, subject_set_id) |> Array.from_list
    Cellect.SubjectSetCache.set_subject_ids({workflow_id, subject_set_id}, subject_ids)
    {:noreply, state}
  end
end
