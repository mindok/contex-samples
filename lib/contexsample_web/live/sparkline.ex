defmodule ContexSampleWeb.SparklineLive do
  use Phoenix.LiveView
  use Phoenix.HTML

  alias Contex.{Sparkline}

  def render(assigns) do
    ~L"""
      <h3>Simple Sparkline Example</h3>
      <div class="container">
        <div class="row">
          <div class="column">

            <form phx-change="chart_options_changed">
              <label for="refresh_rate">Refresh Rate</label>
              <input type="number" name="refresh_rate" id="refresh_rate" placeholder="Enter refresh rate" value=<%= @chart_options.refresh_rate %>>

              <label for="number_of_points">Number of points</label>
              <input type="number" name="number_of_points" id="number_of_points" placeholder="Enter #series" value=<%= @chart_options.number_of_points %>>
            </form>

            <%= make_plot(@test_data) %>Something we're monitoring
            <%= make_red_plot(@test_data) %>Something important we're monitoring

            <p>And here's the data:</p>
            <%= inspect(@test_data) %>
          </div>
        </div>
      </div>

    """

  end

  def mount(_params, socket) do
    socket =
      socket
      |> assign(chart_options: %{refresh_rate: 1000, number_of_points: 50})
      |> assign(process_counts: [0])
      |> make_test_data()

    if connected?(socket), do: Process.send_after(self(), :tick, socket.assigns.chart_options.refresh_rate)

    {:ok, socket}

  end

  def handle_event("chart_options_changed", %{}=params, socket) do
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

  defp make_plot(data) do
    Sparkline.new(data)
    |> Sparkline.draw()
  end

  defp make_red_plot(data) do
    Sparkline.new(data)
    |> Sparkline.colours("#fad48e", "#ff9838")
    |> Sparkline.draw()
  end

  defp make_test_data(socket) do
    number_of_points = socket.assigns.chart_options.number_of_points

    result = 1..number_of_points
       |> Enum.map(fn _ -> :rand.uniform(50) - 100 end)

    assign(socket, test_data: result)
  end

end
