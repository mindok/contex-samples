defmodule ContexSampleWeb.GanttLive do
  use Phoenix.LiveView
  use Phoenix.HTML

  alias Contex.{GanttChart, Dataset, Plot}

  def render(assigns) do
    ~L"""
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

  def mount(_params, socket) do
    {:ok, socket}
  end

  def build_ganttchart() do
    date_min = ~N{2019-10-01 10:00:00}
    interval_us = 3_000 * 1_000_000
    max_points = 15 #random_within_range(min * (x/max_points), max)

    data = 1..max_points
      |> Enum.map(fn x ->
          time_start = Timex.add(date_min, Timex.Duration.from_microseconds(x * interval_us))
          time_end = Timex.add(time_start, Timex.Duration.from_minutes(trunc(random_within_range(15.0, 200.0))))
          ["Category #{div(x, 5)}", "Task #{x}", time_start, time_end ]
        end)

    dataset = Dataset.new(data, ["Cat", "Task", "Start", "End"])
    plot_content = GanttChart.new(dataset)

    plot = Plot.new(600, 400, plot_content)
      |> Plot.titles("Sample Gantt Chart", nil)

    Plot.to_svg(plot)
  end


  defp random_within_range(min, max) do
    diff = max - min
    (:rand.uniform() * diff) + min
  end


end
