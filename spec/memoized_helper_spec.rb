require_relative "./rails_helper"

RSpec.describe AsyncRender::MemoizedHelper, type: :helper do
  include AsyncRender::MemoizedHelper

  let(:view_context) { ActionView::Base.new }

  before do
    allow(self).to receive(:render) do |partial, locals|
      "rendered:#{partial}:#{locals.to_a.sort_by { |(k, _)| k.to_s }}"
    end
    AsyncRender.reset_memoized_cache!
  end

  it "caches output per partial name" do
    a = memoized_render("shared/header", numbers: 1)
    b = memoized_render("shared/header", numbers: 1)
    expect(a).to eq(b)
  end

  it "differentiates by locals" do
    a = memoized_render("shared/header", numbers: 1)
    b = memoized_render("shared/header", numbers: 2)
    expect(a).not_to eq(b)
  end
end
