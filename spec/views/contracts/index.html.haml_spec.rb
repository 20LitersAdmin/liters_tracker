# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "contracts/index", type: :view do
  before(:each) do
    assign(:contracts, [
      Contract.create!(
        :budget => "",
        :household_goal => 2,
        :people_goal => 3
      ),
      Contract.create!(
        :budget => "",
        :household_goal => 2,
        :people_goal => 3
      )
    ])
  end

  it "renders a list of contracts" do
    render
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
  end
end
