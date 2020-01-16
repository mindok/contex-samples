defmodule ContexSampleWeb.BarPlotTimer do
  use Phoenix.LiveView
  use Phoenix.HTML

  import ContexSampleWeb.Shared

  alias Contex.{BarPlot, Plot, Dataset}

  def render(assigns) do
    ~L"""
      <h3>Bar Plot On A Timer Example</h3>
      <div class="container">
        <div class="row">
          <div class="column column-25">

             <form phx-change="chart_options_changed">
              <label for="title">Plot Title</label>
              <input type="text" name="title" id="title" placeholder="Enter title" value=<%= @chart_options.title %>>

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

              <label for="show_selected">Show Clicked Bar</label>
              <%= raw_select("show_selected", "show_selected", yes_no_options(), @chart_options.show_selected) %>

            </form>


          </div>

          <div class="column column-75">
            <%= basic_plot(@test_data, @chart_options) %>
          </div>

        </div>
      </div>

    """

  end

  def mount(_params, socket) do
    socket =
      socket
      |> assign(chart_options: %{categories: 10, series: 4, type: :stacked, orientation: :vertical, show_selected: "no", title: nil, colour_scheme: "themed"})
      |> assign(counter: 0)
      |> make_test_data()

    if connected?(socket), do: Process.send_after(self(), :tick, 100)

    {:ok, socket}

  end

  def handle_event("chart_options_changed", %{}=params, socket) do
    socket =
      socket
      |> update_chart_options_from_params(params)
      |> make_test_data()

    {:noreply, socket}
  end

  def handle_info(:tick, socket) do
    counter = socket.assigns.counter

    Process.send_after(self(), :tick, 100)
    {:noreply, assign(socket, counter: counter + 1) |> make_test_data()}
  end

  def basic_plot(test_data, chart_options) do
    plot_content = BarPlot.new(test_data)
      |> BarPlot.set_val_col_names(chart_options.series_columns)
      |> BarPlot.type(chart_options.type)
      |> BarPlot.orientation(chart_options.orientation)
      |> BarPlot.colours(lookup_colours(chart_options.colour_scheme))
      |> BarPlot.force_value_range({0, chart_options.series * 2.0})

    plot = Plot.new(500, 400, plot_content)
      |> Plot.titles(chart_options.title, nil)

    Plot.to_svg(plot)
  end

  defp make_test_data(socket) do
    options = socket.assigns.chart_options
    series = options.series
    categories = options.categories
    counter = socket.assigns.counter

    data = 1..categories
    |> Enum.map(fn cat ->
      series_data = for s <- 1..series do
        abs(1 + :math.sin((counter + cat + s) / 5.0))
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
end
