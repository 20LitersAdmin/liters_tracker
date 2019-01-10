# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "targets/index", type: :view do
  before(:each) do
    assign(:targets, [
      Target.create!(
        :contract => nil,
        :technology => nil,
        :goal => 2,
        :people_goal => 3
      ),
      Target.create!(
        :contract => nil,
        :technology => nil,
        :goal => 2,
        :people_goal => 3
      )
    ])
  end

  it "renders a list of targets" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
  end
end
