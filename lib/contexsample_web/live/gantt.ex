defmodule ContexSampleWeb.GanttLive do
  use Phoenix.LiveView
  use Phoenix.HTML

  alias Contex.{GanttChart, Dataset, Plot}

  def render(assigns) do
    ~H"""
      <h3>Simple Gantt Chart Example</h3>
      <div class="container">
        <div class="row">
          <div class="column">
            <%= build_ganttchart() %>
          </div>
        </div>
      </div>

    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def build_ganttchart() do
    date_min = ~N{2019-10-01 10:00:00}
    interval_seconds = 3_000
    max_points = 15 # random_within_range(min * (x/max_points), max)

    data = 1..max_points
      |> Enum.map(fn x ->
          time_start = NaiveDateTime.add(date_min, (x * interval_seconds))
          time_end = NaiveDateTime.add(time_start, 60 * trunc(random_within_range(15.0, 200.0)))
          ["Category #{div(x, 5)}", "Task #{x}", time_start, time_end]
        end)

    dataset = Dataset.new(data, ["Cat", "Task", "Start", "End"])

    opts =
      [
        mapping: %{category_col: "Cat", task_col: "Task", start_col: "Start", finish_col: "End"},
        colour_palette: ContexSampleWeb.Shared.lookup_colours("themed")
      ]

    plot
      = Plot.new(dataset, GanttChart, 600, 400, opts)
       |> Plot.titles("Sample Gantt Chart", nil)

    Plot.to_svg(plot)
  end

  defp random_within_range(min, max) do
    diff = max - min
    (:rand.uniform() * diff) + min
  end
end
