defmodule ContexSampleWeb.ScalesLive do
  use Phoenix.LiveView
  use Phoenix.HTML

  alias Contex.{Axis, Scale, TimeScale, ContinuousLinearScale}

  def render(assigns) do
    ~L"""
      <h3>Fun With Scales</h3>
      <div class="container">
        <div class="row">
          <div class="column">
            <table>
            <%= for scale <- @scales do %>
              <tr>
                <td><%= scale.title %></td>
                <td style="text-align:center;"><%= plot_axis(scale) %></td>
              </tr>
            <% end %>
            </table>
          </div>
        </div>
      </div>
    """
  end

  def mount(_params, socket) do
    socket =
      socket
      |> make_test_scales()

    {:ok, socket}
  end

  defp plot_axis(%{scale: scale}=details) do
    formatter = details[:formatter]
    scale = if formatter, do: %{scale | custom_tick_formatter: formatter}, else: scale

    axis = Axis.new_bottom_axis(scale)

    rotation = details[:rotation]
    axis = if rotation, do: %{axis | rotation: rotation}, else: axis
    height = if rotation, do: 60, else: 20

    {d_min, d_max} = scale.domain

    output =
      ~s"""
        <small style="color:#aa3333">Domain: #{d_min}</small> &rarr; <small style="color:#aa3333">#{d_max}</small>
        <svg height="#{height}" width="600" viewBox="-50 0 550 #{height}" >
          #{Axis.to_svg(axis)}
        </svg>
      """

    {:safe, [output]}
  end

  defp make_test_scales(socket) do
    scales = [
      %{title: "Time: Five seconds", scale: make_time_scale(~N[2020-01-01 13:00:00], ~N[2020-01-01 13:00:05])},
      %{title: "Time: Ten seconds", scale: make_time_scale(~N[2020-01-01 13:00:01], ~N[2020-01-01 13:00:10])},
      %{title: "Time: Five minutes", scale: make_time_scale(~N[2020-01-01 13:12:00], ~N[2020-01-01 13:17:00])},
      %{title: "Time: Five minutes, hour rollover", scale: make_time_scale(~N[2020-01-01 13:58:00], ~N[2020-01-01 14:03:00])},
      %{title: "Time: Ten minutes", scale: make_time_scale(~N[2020-01-01 13:00:00], ~N[2020-01-01 13:10:00])},
      %{title: "Time: Five days", scale: make_time_scale(~N[2020-01-01 13:00:00], ~N[2020-01-05 13:00:00]), rotation: 45},
      %{title: "Time: Ten days", scale: make_time_scale(~N[2020-01-01 13:00:00], ~N[2020-01-10 13:00:00])},
      %{title: "Time: One month", scale: make_time_scale(~N[2020-01-01 13:00:00], ~N[2020-02-01 13:00:00])},
      %{title: "Time: Five months", scale: make_time_scale(~N[2020-01-01 13:00:00], ~N[2020-05-01 13:00:00])},
      %{title: "Time: One year", scale: make_time_scale(~N[2019-01-01 13:00:00], ~N[2020-01-01 13:00:00])},
      %{title: "Time: Five years", scale: make_time_scale(~N[2019-01-01 13:00:00], ~N[2024-01-01 13:00:00])},
      %{title: "Time: Ten years", scale: make_time_scale(~N[2019-01-01 13:00:00], ~N[2029-01-01 13:00:00])},
      %{title: "Number: Tiny numbers", scale: make_linear_scale(0.000001, 0.000007), rotation: 45},
      %{title: "Number: Tiny numbers II", scale: make_linear_scale(0.000001, 0.0000111), rotation: 45},
      %{title: "Number: Big numbers", scale: make_linear_scale(1_000_000, 11_000_000), rotation: 45},
      %{title: "Number: Big numbers, more intervals", scale: make_linear_scale(0, 13_000_000, 40), rotation: 45},
      %{title: "Number: Custom formatter", scale: make_linear_scale(1_000_000, 50_000_000), formatter: &million_formatter/1},
    ]

    assign(socket, scales: scales)
  end

  defp make_time_scale(d1, d2) do
    TimeScale.new() |> TimeScale.domain(d1, d2) |> Scale.set_range(0.0, 450.0)
  end

  defp make_linear_scale(d1, d2, intervals \\ 0) do
    ContinuousLinearScale.new()
      |> ContinuousLinearScale.domain(d1, d2)
      |> Scale.set_range(0.0, 450.0)
      |> ContinuousLinearScale.interval_count(intervals)
  end

  defp million_formatter(value) when is_number(value), do: "#{:erlang.float_to_binary(value/1_000_000.0, [decimals: 0])}M"

end
