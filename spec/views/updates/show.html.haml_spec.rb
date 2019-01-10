# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "updates/show", type: :view do
  before(:each) do
    @update = assign(:update, Update.create!(
      :technology => nil,
      :distributed => 2,
      :checked => 3,
      :user => nil,
      :model_gid => "Model Gid",
      :distribute => 4,
      :check => 5
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(//)
    expect(rendered).to match(/Model Gid/)
    expect(rendered).to match(/4/)
    expect(rendered).to match(/5/)
  end
end
