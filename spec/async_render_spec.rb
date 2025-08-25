require "rails_helper"

RSpec.describe "Async render end-to-end", type: :request do
  it "places placeholders and middleware stitches fragments" do
    # Ensure clean per-request state
    AsyncRender::Current.async_futures = Concurrent::Hash.new

    get users_path

    expect(response).to have_http_status(:ok)
    html = response.body

    # No placeholders remain after middleware processing
    expect(html).not_to include("<!--ASYNC-PLACEHOLDER:")

    # Sidebar/header should be present; assert on a stable header text
    expect(html).to include("Header")

    # Page rendered without residual placeholders
  end

  it "replaces placeholder tokens from futures map" do
    AsyncRender::Current.skip_middleware = false
    AsyncRender::Current.async_futures = Concurrent::Hash.new

    # Simulate a page that contains a placeholder and a future value
    token = SecureRandom.hex(10)
    placeholder = "<!--ASYNC-PLACEHOLDER:#{token}-->"
    AsyncRender::Current.async_futures[token] = Concurrent::Promises.future_on(AsyncRender.executor) { "<div id=\"async\">done</div>" }

    app = ->(_env) { [ 200, { "Content-Type" => "text/html" }, [ "<html>#{placeholder}</html>" ] ] }
    mw = AsyncRender::Middleware.new(app)

    status, headers, body = mw.call({})
    result = ""
    body.each { |part| result << part }

    expect(status).to eq(200)
    expect(headers["Content-Type"]).to include("text/html")
    expect(result).to include("<div id=\"async\">done</div>")
    expect(result).not_to include("<!--ASYNC-PLACEHOLDER:")
  end
end
