# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "plans/index", type: :view do
  before(:each) do
    assign(:plans, [
      Plan.create!(
        :contract => nil,
        :technology => nil,
        :model_gid => "Model Gid",
        :goal => 2,
        :people_goal => 3
      ),
      Plan.create!(
        :contract => nil,
        :technology => nil,
        :model_gid => "Model Gid",
        :goal => 2,
        :people_goal => 3
      )
    ])
  end

  it "renders a list of plans" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => "Model Gid".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
  end
end
