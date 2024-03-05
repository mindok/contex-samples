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
    plug :put_root_layout, html: {ContexSampleWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ContexSampleWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/faq", PageController, :faq

    live_session :default, layout: {ContexSampleWeb.Layouts, :live} do
      live "/barcharts", BarChartLive
      live "/barchart_timer", BarChartTimer
      live "/multibar", MultiBarChart
      live "/sparklines", SparklineLive
      live "/gantt", GanttLive
      live "/point", PointPlotLive
      live "/scales", ScalesLive
      live "/piechart", PieChartLive
      live "/simple-piechart", SimplePieChartLive
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", ContexSampleWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:contex_sample, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ContexSampleWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
