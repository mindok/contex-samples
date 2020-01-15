defmodule ContexSampleWeb.BarPlotLive do
  use Phoenix.LiveView
  use Phoenix.HTML

  alias Contex.{BarPlot, Plot, Dataset}

  def render(assigns) do
    ~L"""
      <h3>Simple Bar Plot Example</h3>
      <p>Source code can be found <a href="https://github.com/mindok/contex-samples/blob/master/lib/contexsample_web/live/barplot.ex">on Github</a></p>
      <div class="container">
        <div class="row">
          <div class="column column-25">

            <form phx-change="chart1_options_changed">
              <label for="title">Plot Title</label>
              <input type="text" name="title" id="title" placeholder="Enter title" value=<%= @chart1_options.title %>>

              <label for="series">Number of series</label>
              <input type="number" name="series" id="series" placeholder="Enter #series" value=<%= @chart1_options.series %>>

              <label for="categories">Number of categories</label>
              <input type="number" name="categories" id="categories" placeholder="Enter #categories" value=<%= @chart1_options.categories %>>

              <label for="type">Type</label>
              <%= raw_select("type", "type", chart_type_options(), Atom.to_string(@chart1_options.type)) %>

              <label for="orientation">Orientation</label>
              <%= raw_select("orientation", "orientation", chart_orientation_options(), Atom.to_string(@chart1_options.orientation)) %>

              <label for="colour_scheme">Colour Scheme</label>
              <%= raw_select("colour_scheme", "colour_scheme", colour_options(), @chart1_options.colour_scheme) %>

              <label for="show_selected">Show Clicked Bar</label>
              <%= raw_select("show_selected", "show_selected", yes_no_options(), @chart1_options.show_selected) %>

              </form>

          </div>

          <div class="column column-75">
            <%= basic_plot(@test_data, @chart1_options, @selected_bar) %>

            <%= @bar_clicked %>
          </div>

        </div>
      </div>

    """

  end

  def mount(_params, socket) do
    socket =
      socket
      |> assign(chart1_options: %{categories: 10, series: 4, type: :stacked, orientation: :vertical, show_selected: "no", title: nil, colour_scheme: "default"})
      |> assign(bar_clicked: "Click a bar. Any bar", selected_bar: nil)
      |> make_test_data()

    {:ok, socket}

  end

  def handle_event("chart1_options_changed", %{"show_selected"=> show_selected, "title"=>title, "colour_scheme" => colour_scheme}=params, socket) do
    options =
      socket.assigns.chart1_options
      |> update_if_int(:series, params["series"])
      |> update_if_int(:categories, params["categories"])
      |> update_type(params["type"])
      |> update_orientation(params["orientation"])
      |> Map.put(:show_selected, show_selected)
      |> Map.put(:title, title)
      |> Map.put(:colour_scheme, colour_scheme)

    socket =
      socket
      |> assign(chart1_options: options)
      |> make_test_data()

    {:noreply, socket}
  end

  def handle_event("chart1_bar_clicked", %{"category" => category, "series" => series, "value" => value}=_params, socket) do
    bar_clicked = "You clicked: #{category} / #{series} with value #{value}"
    selected_bar = %{category: category, series: series}

    socket = assign(socket, bar_clicked: bar_clicked, selected_bar: selected_bar)

    {:noreply, socket}
  end

  defp update_if_int(map, key, possible_value) do
    case Integer.parse(possible_value) do
      {val, ""} -> Map.put(map, key, val)
      _ -> map
    end
  end

  defp update_type(options, raw) do
    case raw do
      "stacked" -> Map.put(options, :type, :stacked)
      "grouped" -> Map.put(options, :type, :grouped)
      _-> options
    end
  end

  defp update_orientation(options, raw) do
    case raw do
      "horizontal" -> Map.put(options, :orientation, :horizontal)
      "vertical" -> Map.put(options, :orientation, :vertical)
      _-> options
    end
  end


  def basic_plot(test_data, chart1_options, selected_bar) do
    plot_content = BarPlot.new(test_data)
      |> BarPlot.set_val_col_names(chart1_options.series_columns)
      |> BarPlot.type(chart1_options.type)
      |> BarPlot.orientation(chart1_options.orientation)
      |> BarPlot.event_handler("chart1_bar_clicked")
      |> BarPlot.colours(lookup_colours(chart1_options.colour_scheme))

    plot_content = case chart1_options.show_selected do
      "yes" -> BarPlot.select_item(plot_content, selected_bar)
      _ -> plot_content
    end

    plot = Plot.new(500, 400, plot_content)
      |> Plot.titles(chart1_options.title, nil)

    Plot.to_svg(plot)
  end

  defp lookup_colours("pastel"), do: :pastel1
  defp lookup_colours("default"), do: :default
  defp lookup_colours("warm"), do: :warm
  defp lookup_colours("custom"), do: ["004c6d", "1e6181", "347696", "498caa", "5da3bf", "72bbd4", "88d3ea", "9eebff"]
  defp lookup_colours("nil"), do: nil
  defp lookup_colours(_), do: nil

  defp make_test_data(socket) do
    options = socket.assigns.chart1_options
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

    assign(socket, test_data: test_data, chart1_options: options)
  end

  defp random_within_range(min, max) do
    diff = max - min
    (:rand.uniform() * diff) + min
  end

  defp chart_type_options(), do: simple_option_list(~w(stacked grouped))
  defp chart_orientation_options(), do: simple_option_list(~w(vertical horizontal))
  defp yes_no_options(), do: simple_option_list(~w(yes no))
  defp colour_options(), do: simple_option_list(~w(default custom warm pastel nil))


  defp simple_option_list(options), do: Enum.map(options, &%{name: &1, value: &1})

  defp raw_select(name, id, options, current_item) do
    beginning_bit = ~E|<select  type="select" name="<%= name %>" id="<%= id %>">|

    middle_bit = Enum.map(options, fn o ->
      selected = if o.value == current_item, do: "selected", else: ""
      ~E|<option value="<%= o.value %>" <%= selected %>><%= o.name %></option>|
    end)

    end_bit = ~E|</select>|
    [beginning_bit, middle_bit, end_bit]
  end


end
