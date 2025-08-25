require "rails_helper"
require "json"

RSpec.describe "Warmups", type: :controller do
  controller(ApplicationController) do
    warmups do
      warmup_render "shared/head"
      warmup_render "shared/sidebar", a: 1
      warmup_render "shared/modal"
    end

    def index
      keys = AsyncRender::Current.warmup_partials.keys
      render json: { keys: keys }
    end
  end

  before do
    routes.draw { get "index" => "anonymous#index" }
    AsyncRender::Current.warmup_partials = Concurrent::Hash.new
  end

  it "schedules warmup renders and stores placeholders keyed by partial + locals" do
    get :index
    keys = JSON.parse(response.body)["keys"]
    # Keys contain partial+locals; verify presence by partial names
    expect(keys.any? { |k| Array(k).first == "shared/head" }).to be(true)
    expect(keys.any? { |k| Array(k).first == "shared/sidebar" }).to be(true)
    expect(keys.any? { |k| Array(k).first == "shared/modal" }).to be(true)
  end
end
