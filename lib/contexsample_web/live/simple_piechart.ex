defmodule ContexSampleWeb.SimplePieChartLive do
  use Phoenix.LiveView
  use Phoenix.HTML

  alias Contex.SimplePie

  def render(assigns) do
    ~H"""
      <h3>Simple Pie Chart Example</h3>
      <div class="container">
        <div class="row">
          <div class="column">
            <form phx-change="chart_options_changed">
              <label for="refresh_rate">Refresh Rate</label>
              <input type="number" name="refresh_rate" id="refresh_rate" placeholder="Enter refresh rate" value={@chart_options.refresh_rate}>

              <label for="number_of_categories">Number of categories</label>
              <input type="number" name="number_of_categories" id="number_of_categories" placeholder="Enter #series" value={@chart_options.number_of_categories}>
            </form>

            <table>
              <thead>
                <tr>
                  <th>SVG</th>
                  <th>Data</th>
                </tr>
              </thead>
              <tbody>
                <%= for data <- @simple_pie_data do %>
                  <tr>
                    <th>
                      <%= make_simple_pie(data) %>
                    </th>
                    <td>
                      <code><%= inspect(data) %></code>
                    </td>
                  </tr>
                <% end %>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    """
  end

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(chart_options: %{refresh_rate: 5_000, number_of_categories: 4})
      |> make_test_data()

    if connected?(socket),
      do: Process.send_after(self(), :tick, socket.assigns.chart_options.refresh_rate)

    {:ok, socket}
  end

  def handle_event("chart_options_changed", %{} = params, socket) do
    options =
      socket.assigns.chart_options
      |> update_if_positive_int(:number_of_categories, params["number_of_categories"])
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

  defp make_simple_pie(data) do
    SimplePie.new(data)
    |> SimplePie.draw()
  end

  defp make_test_data(socket) do
    number_of_categories = socket.assigns.chart_options.number_of_categories

    simple_pie_data =
      Enum.map(1..3, fn _ ->
        1..number_of_categories
        |> Enum.map(fn i -> {"Category ##{i}", :rand.uniform(100)} end)
      end)

    assign(socket, simple_pie_data: simple_pie_data)
  end
end
