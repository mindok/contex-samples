defmodule ContexSampleWeb.Router do
  require Logger
  use ContexSampleWeb, :router

  def basic_log(conn, _opts) do
    # live routes don't emit logs with request path
    ip = conn.remote_ip |> Tuple.to_list() |> Enum.join(".")
    Logger.info("Requested #{conn.request_path} from #{ip}")
    conn
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug RemoteIp
    plug :basic_log
    plug :fetch_session
    plug :fetch_live_flash
#    plug :fetch_flash
#    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", ContexSampleWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/faq", PageController, :faq

#    live "/barcharts", BarChartLive, session: ["remote_ip"]
    live "/barcharts", BarChartLive, layout: {ContexSampleWeb.LayoutView, :root}
    live "/barchart_timer", BarChartTimer, layout: {ContexSampleWeb.LayoutView, :root}
    live "/multibar", MultiBarChart, layout: {ContexSampleWeb.LayoutView, :root}
    live "/sparklines", SparklineLive, layout: {ContexSampleWeb.LayoutView, :root}
    live "/gantt", GanttLive, layout: {ContexSampleWeb.LayoutView, :root}
    live "/point", PointPlotLive, layout: {ContexSampleWeb.LayoutView, :root}
    live "/scales", ScalesLive, layout: {ContexSampleWeb.LayoutView, :root}
    live "/piechart", PieChartLive, layout: {ContexSampleWeb.LayoutView, :root}
    live "/simple-piechart", SimplePieChartLive, layout: {ContexSampleWeb.LayoutView, :root}
  end

end
