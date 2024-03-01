defmodule ContexSampleWeb.BarChartComponent do
  use Phoenix.LiveComponent
  use Phoenix.HTML

  alias Contex.{BarChart, Plot, Dataset}

  def render(assigns) do
    ~H"""
    <div>
      <div>My id is: <%= @myself %></div>
      <div><%= basic_plot(@dataset, @series_cols, @myself, @selected_bar) %></div>

      <button class="button button-outline" phx-click="clear" phx-target={@myself}>Clear</button>
      <span><em><%= @bar_clicked %></em></span>
    </div>
    """
  end

  def mount(socket) do
    {:ok, socket}
  end

  def update(_assigns, socket) do
    socket = make_data(socket) |> assign(selected_bar: nil, bar_clicked: raw("&nbsp"))
    {:ok, socket}
  end

  def handle_event("bar_clicked", %{"category" => category, "series" => series, "value" => value}=_params, socket) do
    {value, _} = Float.parse(value)
    bar_clicked = "#{category} / #{series} with value #{trunc(value)}"
    selected_bar = %{category: category, series: series}

    socket = assign(socket, bar_clicked: bar_clicked, selected_bar: selected_bar)

    {:noreply, socket}
  end

  def handle_event("clear", _params, socket) do
    socket = assign(socket, bar_clicked: raw("&nbsp"), selected_bar: nil)

    {:noreply, socket}

  end

  defp make_data(socket) do
    categories = 10
    series = 4

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

    assign(socket, dataset: test_data, series_cols: series_cols)
  end

  defp basic_plot(data, series_cols, target_id, selected_item) do
    options = [
      mapping: %{category_col: "Category", value_cols: series_cols},
      orientation: :vertical,
      colour_palette: ["ff9838", "fdae53", "fbc26f", "fad48e", "fbe5af", "fff5d1"],
      phx_event_handler: "bar_clicked",
      phx_event_target: inspect(target_id.cid),
      select_item: selected_item
    ]

    plot = Plot.new(data, BarChart, 400, 300, options)
      |> Plot.titles("Sample Bar Chart", nil)

    Plot.to_svg(plot)
  end

  defp random_within_range(min, max) do
    diff = max - min
    (:rand.uniform() * diff) + min
  end
end

defmodule ContexSampleWeb.MultiBarChart do
  use Phoenix.LiveView
  use Phoenix.HTML

  def render(assigns) do
    ~H"""
    <div>
    <section class="row">
      <article class="column">
        <.live_component module={ContexSampleWeb.BarChartComponent} id="1" />
      </article>
      <article class="column">
        <.live_component module={ContexSampleWeb.BarChartComponent} id="2" />
      </article>
    </section>
    <section class="row">
      <article class="column">
        <.live_component module={ContexSampleWeb.BarChartComponent} id="3" />
      </article>
      <article class="column">
        <.live_component module={ContexSampleWeb.BarChartComponent} id="4" />
      </article>
    </section>
    </div>
    """
  end
end
