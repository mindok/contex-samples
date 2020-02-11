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
    plug :basic_log
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", ContexSampleWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/faq", PageController, :faq

    live "/barcharts", BarChartLive, session: [:remote_ip]
    live "/barchart_timer", BarChartTimer
    live "/sparklines", SparklineLive
    live "/gantt", GanttLive
    live "/point", PointPlotLive
  end

end
