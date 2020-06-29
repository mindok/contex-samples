defmodule ContexSampleWeb.PointPlotLive do
  use Phoenix.LiveView
  use Phoenix.HTML

  import ContexSampleWeb.Shared

  alias Contex.{PointPlot, Dataset, Plot}

  def render(assigns) do
    ~L"""
      <h3>Simple Point Plot Example</h3>
      <div class="container">
        <div class="row">
          <div class="column column-25">
            <form phx-change="chart_options_changed">
              <label for="title">Plot Title</label>
              <input type="text" name="title" id="title" placeholder="Enter title" value=<%= @chart_options.title %>>

              <label for="series">Number of series</label>
              <input type="number" name="series" id="series" placeholder="Enter #series" value=<%= @chart_options.series %>>

              <label for="points">Number of points</label>
              <input type="number" name="points" id="points" placeholder="Enter #series" value=<%= @chart_options.points %>>

              <label for="colour_scheme">Colour Scheme</label>
              <%= raw_select("colour_scheme", "colour_scheme", colour_options(), @chart_options.colour_scheme) %>

              <label for="show_legend">Show Legend</label>
              <%= raw_select("show_legend", "show_legend", yes_no_options(), @chart_options.show_legend) %>

              <label for="time_series">Time Series</label>
              <%= raw_select("time_series", "time_series", yes_no_options(), @chart_options.time_series) %>
            </form>
          </div>

          <div class="column">
            <%= build_pointplot(@test_data, @chart_options) %>
            <%= list_to_comma_string(@chart_options[:friendly_message]) %>
          </div>
        </div>
      </div>
    """

  end

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(chart_options: %{series: 4, points: 100, title: nil, colour_scheme: "default", show_legend: "no", time_series: "no"})
      |> make_test_data()

    {:ok, socket}
  end

  def handle_event("chart_options_changed", %{}=params, socket) do
    socket =
      socket
      |> update_chart_options_from_params(params)
      |> make_test_data()

    {:noreply, socket}
  end


  def build_pointplot(dataset, chart_options) do

    plot_content = PointPlot.new(dataset)
      |> PointPlot.set_y_col_names(chart_options.series_columns)
      |> PointPlot.colours(lookup_colours(chart_options.colour_scheme))

    options = case chart_options.show_legend do
      "yes" -> %{legend_setting: :legend_right}
      _ -> %{}
    end


    plot = Plot.new(600, 400, plot_content)
      |> Plot.titles(chart_options.title, nil)
      |> Plot.plot_options(options)

    Plot.to_svg(plot)
  end

  defp make_test_data(socket) do
    options = socket.assigns.chart_options
    time_series = (options.time_series == "yes")
    series = options.series
    points = options.points

    data = for i <- 1..points do
      x = random_within_range(0.0, 30 + (i * 3.0))
      series_data = for s <- 1..series do
        (s * 8.0) + random_within_range(x * (0.1 * s), x * (0.15 * s))
      end
      [calc_x(x, i, time_series) | series_data]
    end

    series_cols = for s <- 1..series do
      "Series #{s}"
    end

    test_data = Dataset.new(data, ["X" | series_cols])

    options = Map.put(options, :series_columns, series_cols)

    assign(socket, test_data: test_data, chart_options: options)
  end

  @date_min ~N{2019-10-01 10:00:00}
  @interval_us 600 * 1_000_000
  defp calc_x(x, _, false), do: x
  defp calc_x(_, i, _) do
    Timex.add(@date_min, Timex.Duration.from_microseconds(i * @interval_us))
  end


  defp random_within_range(min, max) do
    diff = max - min
    (:rand.uniform() * diff) + min
  end


end
