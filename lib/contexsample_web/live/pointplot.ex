defmodule ContexSampleWeb.PointPlotLive do
  use Phoenix.LiveView
  use Phoenix.HTML

  import ContexSampleWeb.Shared

  alias Contex.{LinePlot, PointPlot, Dataset, Plot}

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

              <label for="type">Type</label>
              <%= raw_select("type", "type", simple_option_list(~w(point line)), @chart_options.type) %>

              <label for="type">Smoothed</label>
              <%= raw_select("smoothed", "smoothed", yes_no_options(), @chart_options.smoothed) %>

              <label for="colour_scheme">Colour Scheme</label>
              <%= raw_select("colour_scheme", "colour_scheme", colour_options(), @chart_options.colour_scheme) %>

              <label for="show_legend">Show Legend</label>
              <%= raw_select("show_legend", "show_legend", yes_no_options(), @chart_options.show_legend) %>

              <label for="show_legend">Custom X Scale</label>
              <%= raw_select("custom_x_scale", "custom_x_scale", yes_no_options(), @chart_options.custom_x_scale) %>

              <label for="show_legend">Custom Y Scale</label>
              <%= raw_select("custom_y_scale", "custom_y_scale", yes_no_options(), @chart_options.custom_y_scale) %>

              <label for="show_legend">Custom Y Ticks</label>
              <%= raw_select("custom_y_ticks", "custom_y_ticks", yes_no_options(), @chart_options.custom_y_ticks) %>

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
      |> assign(chart_options: %{
          series: 4,
          points: 30,
          title: nil,
          type: "point",
          smoothed: "yes",
          colour_scheme: "default",
          show_legend: "no",
          custom_x_scale: "no",
          custom_y_scale: "no",
          custom_y_ticks: "no",
          time_series: "no"
          })
      |> assign(prev_series: 0, prev_points: 0, prev_time_series: nil)
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
    y_tick_formatter = case chart_options.custom_y_ticks do
      "yes" -> &custom_axis_formatter/1
      _ -> nil
    end

    module = case chart_options.type do
      "line" -> LinePlot
      _ -> PointPlot
    end

    custom_x_scale = make_custom_x_scale(chart_options)
    custom_y_scale = make_custom_y_scale(chart_options)

    options = [
      mapping: %{x_col: "X", y_cols: chart_options.series_columns},
      colour_palette: lookup_colours(chart_options.colour_scheme),
      custom_x_scale: custom_x_scale,
      custom_y_scale: custom_y_scale,
      custom_y_formatter: y_tick_formatter,
      smoothed: (chart_options.smoothed == "yes")
    ]

    plot_options = case chart_options.show_legend do
      "yes" -> %{legend_setting: :legend_right}
      _ -> %{}
    end


    plot = Plot.new(dataset, module, 600, 400, options)
      |> Plot.titles(chart_options.title, nil)
      |> Plot.plot_options(plot_options)

    Plot.to_svg(plot)
  end

  defp make_test_data(socket) do
    options = socket.assigns.chart_options
    time_series = (options.time_series == "yes")
    prev_series = socket.assigns.prev_series
    prev_points = socket.assigns.prev_points
    prev_time_series = socket.assigns.prev_time_series
    series = options.series
    points = options.points

    needs_update = (prev_series != series) or (prev_points != points) or (prev_time_series != time_series)

    data = for i <- 1..points do
      x = (i * 5) + random_within_range(0.0, 3.0)
      series_data = for s <- 1..series do
        (s * 8.0) + random_within_range(x * (0.1 * s), x * (0.35 * s))
      end
      [calc_x(x, i, time_series) | series_data]
    end

    series_cols = for s <- 1..series do
      "Series #{s}"
    end

    test_data = case needs_update do
      true ->  Dataset.new(data, ["X" | series_cols])
      _ -> socket.assigns.test_data
    end

    options = Map.put(options, :series_columns, series_cols)

    assign(socket,
      test_data: test_data,
      chart_options: options,
      prev_series: series,
      prev_points: points,
      prev_time_series: time_series
    )
  end

  @date_min ~N{2019-10-01 10:00:00}
  @interval_seconds 600
  defp calc_x(x, _, false), do: x
  defp calc_x(_, i, _) do
    NaiveDateTime.add(@date_min, (i * @interval_seconds))
  end


  defp random_within_range(min, max) do
    diff = max - min
    (:rand.uniform() * diff) + min
  end

  def custom_axis_formatter(value) when is_float(value) do
    "V #{:erlang.float_to_binary(value/1_000.0, [decimals: 2])}K"
  end

  def custom_axis_formatter(value) do
    "V #{value}"
  end

  defp make_custom_x_scale(%{custom_x_scale: x}=_chart_options) when x != "yes", do: nil
  defp make_custom_x_scale(chart_options) do
    points = chart_options.points
    case (chart_options.time_series == "yes") do
      true ->
        Contex.TimeScale.new()
        |> Contex.TimeScale.domain(
            @date_min,
            NaiveDateTime.add(@date_min, trunc(points * 1.2 * @interval_seconds))
            )

      _ ->
        Contex.ContinuousLinearScale.new()
        |> Contex.ContinuousLinearScale.domain(0, 100)
        |> Contex.ContinuousLinearScale.interval_count(20)

    end
  end

  defp make_custom_y_scale(%{custom_y_scale: x}=_chart_options) when x != "yes", do: nil
  defp make_custom_y_scale(_chart_options) do
    Contex.ContinuousLinearScale.new()
    |> Contex.ContinuousLinearScale.domain(0, 100)
    |> Contex.ContinuousLinearScale.interval_count(20)
  end


end
