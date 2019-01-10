# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "plans/show", type: :view do
  before(:each) do
    @plan = assign(:plan, Plan.create!(
      :contract => nil,
      :technology => nil,
      :model_gid => "Model Gid",
      :goal => 2,
      :people_goal => 3
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/Model Gid/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
  end
end
