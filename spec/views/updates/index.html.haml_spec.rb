# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "updates/index", type: :view do
  before(:each) do
    assign(:updates, [
      Update.create!(
        :technology => nil,
        :distributed => 2,
        :checked => 3,
        :user => nil,
        :model_gid => "Model Gid",
        :distribute => 4,
        :check => 5
      ),
      Update.create!(
        :technology => nil,
        :distributed => 2,
        :checked => 3,
        :user => nil,
        :model_gid => "Model Gid",
        :distribute => 4,
        :check => 5
      )
    ])
  end

  it "renders a list of updates" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => "Model Gid".to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
    assert_select "tr>td", :text => 5.to_s, :count => 2
  end
end
