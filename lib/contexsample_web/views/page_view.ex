defmodule ContexSampleWeb.PageView do
  use ContexSampleWeb, :view

  alias Contex.{Dataset, BarPlot, Plot, PointPlot, Sparkline}

  def make_a_basic_bar_chart() do
    %{dataset: dataset, series_cols: series_cols} = make_test_bar_data(10, 4)
    plot_content = BarPlot.new(dataset)
    |> BarPlot.set_val_col_names(series_cols)
    |> BarPlot.colours(["ff9838", "fdae53", "fbc26f", "fad48e", "fbe5af", "fff5d1"])


    plot = Plot.new(500, 300, plot_content)
      |> Plot.titles("Sample Bar Chart", nil)
      |> Plot.plot_options(%{legend_setting: :legend_right})

    Plot.to_svg(plot)
  end

  def make_a_basic_bar_chart2() do
    %{dataset: dataset, series_cols: series_cols} = make_test_bar_data(10, 4)
    plot_content = BarPlot.new(dataset)
    |> BarPlot.set_val_col_names(series_cols)
    |> BarPlot.orientation(:horizontal)
    |> BarPlot.colours(["ff9838", "fdae53", "fbc26f", "fad48e", "fbe5af", "fff5d1"])


    plot = Plot.new(500, 300, plot_content)
      |> Plot.titles("Sample Bar Chart", nil)

    Plot.to_svg(plot)
  end

  def make_a_basic_point_plot() do
    dataset = make_test_point_data(300)
    plot_content = PointPlot.new(dataset)
    |> PointPlot.set_y_col_names(["Something", "Another"])

    plot = Plot.new(500, 300, plot_content)
      |> Plot.titles("Sample Scatter Plot", nil)
      |> Plot.plot_options(%{legend_setting: :legend_right})

    Plot.to_svg(plot)
  end

  defp sparkline(data) do
    Sparkline.new(data)
    |> Sparkline.draw()
  end

  defp make_test_bar_data(categories, series) do
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

    %{dataset: test_data, series_cols: series_cols}
  end

  defp make_test_point_data(points) do
    data = for _ <- 1..points do
      x = random_within_range(0.0, 100.0)
      y = random_within_range(x * 0.7, x * 0.8)
      y2 = random_within_range(x * 0.4, x * 0.6)
      {x, y, y2}
    end

    Dataset.new(data, ["X", "Something", "Another"])
  end


  defp random_within_range(min, max) do
    diff = max - min
    (:rand.uniform() * diff) + min
  end


end

