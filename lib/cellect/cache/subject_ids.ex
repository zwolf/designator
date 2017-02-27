defmodule Cellect.Cache.SubjectIds do
  use ExActor.GenServer, export: :subject_ids_cache

  defstart start_link() do
    initial_state %{}
  end

  defcall status(), state: state do
    reply(Enum.map(state, fn {key, val} ->
      case key do
        :reloading -> %{"meta" => %{"reloading" => to_string(val)}}
        _ -> %{"workflow_id" => to_string(key),
               "subject_sets" => Enum.map(val, fn {subject_set_id, ids} ->
                  %{"subject_set_id" => to_string(subject_set_id),
                    "size" => Array.size(ids)}
                end)}
      end
    end))
  end

  defcall get(workflow_id), state: state do
    case state[workflow_id] do
      nil ->
        reload_async(workflow_id)
        reply([])
      ids ->
        if Enum.empty?(ids), do: reload_async(workflow_id)
        reply(ids)
    end
  end

  defcast set(workflow_id, ids), state: state do
    new_state Map.merge(state, %{workflow_id => ids, reloading: false})
  end

  defcast reload_async(workflow_id), state: state do
    if state[:reloading] do
      noreply
    else
      Cellect.Cache.Reloader.reload_workflow(__MODULE__, workflow_id)
      new_state Map.put(state, :reloading, true)
    end
  end

  defcast unlock_reload(workflow_id), state: state do
    if state[:reloading] do
      new_state Map.put(state, :reloading, false)
    else
      noreply
    end
  end
end
