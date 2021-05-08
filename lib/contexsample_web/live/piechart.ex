defmodule ContexSampleWeb.PieChartLive do
  use Phoenix.LiveView
  use Phoenix.HTML

  alias Contex.PieChart

  def render(assigns) do
    ~L"""
      <h3>Simple Pie Chart Example</h3>
      <div class="container">
        <div class="row">
          <div class="column">
            <form phx-change="chart_options_changed">
              <label for="refresh_rate">Refresh Rate</label>
              <input type="number" name="refresh_rate" id="refresh_rate" placeholder="Enter refresh rate" value=<%= @chart_options.refresh_rate %>>

              <label for="number_of_points">Number of points</label>
              <input type="number" name="number_of_points" id="number_of_points" placeholder="Enter #series" value=<%= @chart_options.number_of_points %>>
            </form>

            <%= make_piechart(@test_data) %>
            <p>And here's the data:</p>
            <code><%= inspect(@test_data) %></code>
          </div>
        </div>
      </div>
    """
  end

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(chart_options: %{refresh_rate: 5_000, number_of_points: 4})
      |> make_test_data()

    if connected?(socket),
      do: Process.send_after(self(), :tick, socket.assigns.chart_options.refresh_rate)

    {:ok, socket}
  end

  def handle_event("chart_options_changed", %{} = params, socket) do
    options =
      socket.assigns.chart_options
      |> update_if_positive_int(:number_of_points, params["number_of_points"])
      |> update_if_positive_int(:refresh_rate, params["refresh_rate"])

    socket = assign(socket, chart_options: options)

    {:noreply, socket}
  end

  def handle_info(:tick, socket) do
    Process.send_after(self(), :tick, socket.assigns.chart_options.refresh_rate)

    socket =
      socket
      |> make_test_data()

    {:noreply, socket}
  end

  defp update_if_positive_int(map, key, possible_value) do
    case Integer.parse(possible_value) do
      {val, ""} ->
        if val > 0, do: Map.put(map, key, val), else: map

      _ ->
        map
    end
  end

  defp make_piechart(dataset) do
    PieChart.new(dataset)
    |> PieChart.draw()
  end

  defp make_test_data(socket) do
    number_of_points = socket.assigns.chart_options.number_of_points

    {values, categories} =
      1..number_of_points
      |> Enum.map(fn i -> {:rand.uniform(100), "Category ##{i}"} end)
      |> Enum.unzip()

    assign(socket, test_data: Contex.Dataset.new(values, categories))
  end
end
