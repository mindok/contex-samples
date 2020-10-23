defmodule ContexSampleWeb.BarChartLive do
  use Phoenix.LiveView
  use Phoenix.HTML

  import ContexSampleWeb.Shared

  alias Contex.{BarChart, Plot, Dataset}

  def render(assigns) do
    ~L"""
      <style><%= get_code_highlighter_styles() %></style>
      <h3>Simple Bar Chart Example</h3>
      <p>Source code can be found <a href="https://github.com/mindok/contex-samples/blob/master/lib/contexsample_web/live/barchart.ex">on Github</a></p>
      <div class="container">
        <div class="row">
          <div class="column column-25">

            <form phx-change="chart_options_changed">
              <label for="title">Plot Title</label>
              <input type="text" name="title" id="title" placeholder="Enter title" value=<%= @chart_options.title %>>

              <label for="title">Sub Title</label>
              <input type="text" name="subtitle" id="subtitle" placeholder="Enter subtitle" value=<%= @chart_options.subtitle %>>

              <label for="series">Number of series</label>
              <input type="number" name="series" id="series" placeholder="Enter #series" value=<%= @chart_options.series %>>

              <label for="categories">Number of categories</label>
              <input type="number" name="categories" id="categories" placeholder="Enter #categories" value=<%= @chart_options.categories %>>

              <label for="type">Type</label>
              <%= raw_select("type", "type", chart_type_options(), Atom.to_string(@chart_options.type)) %>

              <label for="orientation">Orientation</label>
              <%= raw_select("orientation", "orientation", chart_orientation_options(), Atom.to_string(@chart_options.orientation)) %>

              <label for="colour_scheme">Colour Scheme</label>
              <%= raw_select("colour_scheme", "colour_scheme", colour_options(), @chart_options.colour_scheme) %>

              <label for="show_legend">Show Legend</label>
              <%= raw_select("show_legend", "show_legend", yes_no_options(), @chart_options.show_legend) %>

              <label for="show_legend">Show Axis Labels</label>
              <%= raw_select("show_axislabels", "show_axislabels", yes_no_options(), @chart_options.show_axislabels) %>

              <label for="show_data_labels">Show Data Labels</label>
              <%= raw_select("show_data_labels", "show_data_labels", yes_no_options(), @chart_options.show_data_labels) %>

              <label for="show_legend">Custom Value Scale</label>
              <%= raw_select("custom_value_scale", "custom_value_scale", yes_no_options(), @chart_options.custom_value_scale) %>

              <label for="show_selected">Show Clicked Bar</label>
              <%= raw_select("show_selected", "show_selected", yes_no_options(), @chart_options.show_selected) %>
            </form>

          </div>

          <div class="column column-75">
            <%= basic_plot(@test_data, @chart_options, @selected_bar) %>

            <p><em><%= @bar_clicked %></em></p>
            <%= list_to_comma_string(@chart_options[:friendly_message]) %>

            <h4>Code</h4>
            <%= plot_code(@chart_options, @selected_bar) %>
          </div>

        </div>
      </div>

    """

  end

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(chart_options: %{
            categories: 10,
            series: 3,
            type: :stacked,
            orientation: :vertical,
            show_data_labels: "yes",
            show_selected: "no",
            show_axislabels: "no",
            custom_value_scale: "no",
            title: nil,
            subtitle: nil,
            colour_scheme: "themed",
            show_legend: "no"
        })
      |> assign(bar_clicked: "Click a bar. Any bar", selected_bar: nil)
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

  def handle_event("chart1_bar_clicked", %{"category" => category, "series" => series, "value" => value}=_params, socket) do
    bar_clicked = "You clicked: #{category} / #{series} with value #{value}"
    selected_bar = %{category: category, series: series}

    socket = assign(socket, bar_clicked: bar_clicked, selected_bar: selected_bar)

    {:noreply, socket}
  end

  def basic_plot(test_data, chart_options, selected_bar) do

    selected_item = case chart_options.show_selected do
      "yes" -> selected_bar
      _ -> nil
    end

    custom_value_scale = make_custom_value_scale(chart_options)

    options = [
      mapping: %{category_col: "Category", value_cols: chart_options.series_columns},
      type: chart_options.type,
      data_labels: (chart_options.show_data_labels == "yes"),
      orientation: chart_options.orientation,
      phx_event_handler: "chart1_bar_clicked",
      custom_value_scale: custom_value_scale,
      colour_palette: lookup_colours(chart_options.colour_scheme),
      select_item: selected_item
    ]

    plot_options = case chart_options.show_legend do
      "yes" -> %{legend_setting: :legend_right}
      _ -> %{}
    end

    {x_label, y_label} = case chart_options.show_axislabels do
      "yes" -> {"x-axis", "y-axis"}
      _ -> {nil, nil}
    end

    plot = Plot.new(test_data, BarChart, 500, 400, options)
      |> Plot.titles(chart_options.title, chart_options.subtitle)
      |> Plot.axis_labels(x_label, y_label)
      |> Plot.plot_options(plot_options)

    Plot.to_svg(plot)
  end

  def plot_code(chart_options, selected_bar) do

    select_item_line = case chart_options.show_selected do
      "yes" ->
        if is_nil(selected_bar) do
          ~s|nil|
        else
          ~s|%{category: "#{selected_bar.category}", series: "#{selected_bar.series}"}|
        end
      _ -> ""
    end

    options = case chart_options.show_legend do
      "yes" -> "%{legend_setting: :legend_right}"
      _ -> "%{}"
    end

    {x_label, y_label} = case chart_options.show_axislabels do
      "yes" -> {"x-axis", "y_axis"}
      _ -> {nil, nil}
    end

    custom_value_scale = case chart_options.custom_value_scale do
      "yes" ->
        """
        custom_value_scale = Contex.ContinuousLinearScale.new()
          |> Contex.ContinuousLinearScale.domain(0, 500)
          |> Contex.ContinuousLinearScale.interval_count(25)
        """
        _ -> ""
    end

    code = ~s"""
    #{custom_value_scale}
    options = [
      mapping: %{category_col: "Category", value_cols: #{inspect(chart_options.series_columns)}},
      type: #{inspect(chart_options.type)},
      data_labels: #{inspect((chart_options.show_data_labels == "yes"))},
      orientation: #{inspect(chart_options.orientation)},
      phx_event_handler: "chart1_bar_clicked",
      colour_palette: #{inspect(lookup_colours(chart_options.colour_scheme))},
      select_item: #{select_item_line},
      #{if custom_value_scale != "" do "custom_value_scale: custom_value_scale" end}
    ]

    plot = Plot.new(test_data, BarChart, 500, 400, options)
      |> Plot.titles("#{chart_options.title}", "#{chart_options.subtitle}")
      |> Plot.axis_labels("#{x_label}", "#{y_label}")
      |> Plot.plot_options(#{options})
    """

    {:safe, Makeup.highlight(code)}
  end

  defp make_test_data(socket) do
    options = socket.assigns.chart_options
    series = options.series
    categories = options.categories

    data = 1..categories
    |> Enum.map(fn cat ->
      series_data = for _ <- 1..series do
        random_within_range(10.0, 100.0)
      end
      ["Category #{cat}" | series_data]
    end)

    series_cols = for i <- 1..series do
      "Series #{i}"
    end

    test_data = Dataset.new(data, ["Category" | series_cols])

    options = Map.put(options, :series_columns, series_cols)

    assign(socket, test_data: test_data, chart_options: options)
  end

  defp random_within_range(min, max) do
    diff = max - min
    (:rand.uniform() * diff) + min
  end

  defp make_custom_value_scale(%{custom_value_scale: x}=_chart_options) when x != "yes", do: nil
  defp make_custom_value_scale(_chart_options) do
    Contex.ContinuousLinearScale.new()
    |> Contex.ContinuousLinearScale.domain(0, 500)
    |> Contex.ContinuousLinearScale.interval_count(25)
  end


  defp get_code_highlighter_styles() do
    style = Makeup.Styles.HTML.StyleMap.friendly_style
    css = Makeup.stylesheet(style)
    {:safe, css}
  end

end
