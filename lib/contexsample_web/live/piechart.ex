defmodule ContexSampleWeb.PieChartLive do
  use Phoenix.LiveView
  use Phoenix.HTML

  import ContexSampleWeb.Shared

  alias Contex.PieChart

  def render(assigns) do
    ~H"""
      <h3>Pie Chart Example</h3>
      <div class="container">
        <div class="row">
          <div class="column column-25">
            <form phx-change="chart_options_changed">
              <label for="title">Pie Title</label>
              <input type="text" name="title" id="title" placeholder="Enter title" value={@chart_options.title}>

              <label for="colour_scheme">Colour Scheme</label>
              <.raw_select name={"colour_scheme"} id={"colour_scheme"} options={colour_options()} current_item={@chart_options.colour_scheme}/>

              <label for="categories">Number of categories</label>
              <input type="number" name="categories" id="categories" placeholder="Enter #series" value={@chart_options.categories}>

              <label for="legend_setting">Legend</label>
              <.raw_select name={"legend_setting"} id={"legend_setting"} options={legend_options()} current_item={@chart_options.legend_setting}/>

              <label for="show_data_labels">Show Data Labels</label>
              <.raw_select name={"show_data_labels"} id={"show_data_labels"} options={yes_no_options()} current_item={@chart_options.show_data_labels}/>
            </form>
          </div> <!-- column-23 -->

          <div class="column column-75">
            <%= build_pieplot(assigns) %>
          </div>
        </div>
      </div>
    """
  end

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(
        chart_options: %{
          categories: 4,
          colour_scheme: "default",
          legend_setting: "legend_none",
          show_data_labels: "yes",
          title: ""
        }
      )
      |> make_test_data()

    {:ok, socket}
  end

  def handle_event("chart_options_changed", %{} = params, socket) do
    socket =
      socket
      |> update_chart_options_from_params(params)
      |> make_test_data()

    {:noreply, socket}
  end

  defp build_pieplot(%{dataset: dataset, chart_options: chart_options}) do
    options = [
      mapping: %{category_col: "Category", value_col: "Preference"},
      data_labels: chart_options.show_data_labels == "yes",
      colour_palette: lookup_colours(chart_options.colour_scheme)
    ]

    plot_options =
      case chart_options.legend_setting do
        "legend_right" -> %{legend_setting: :legend_right}
        "legend_top" -> %{legend_setting: :legend_top}
        "legend_bottom" -> %{legend_setting: :legend_bottom}
        _ -> %{}
      end

    plot_options = Map.put(plot_options, :show_x_axis, false)

    plot =
      Contex.Plot.new(dataset, PieChart, 600, 400, options)
      |> Contex.Plot.titles(chart_options.title, nil)
      |> Contex.Plot.plot_options(plot_options)

    Contex.Plot.to_svg(plot)
  end

  defp make_test_data(socket) do
    categories = socket.assigns.chart_options.categories

    data =
      1..categories
      |> Enum.map(fn i -> {"Category ##{i}", :rand.uniform(100)} end)

    dataset = Contex.Dataset.new(data, ["Category", "Preference"])

    assign(socket, dataset: dataset)
  end
end
