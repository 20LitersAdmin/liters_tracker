# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "plans/new", type: :view do
  before(:each) do
    assign(:plan, Plan.new(
      :contract => nil,
      :technology => nil,
      :model_gid => "MyString",
      :goal => 1,
      :people_goal => 1
    ))
  end

  it "renders new plan form" do
    render

    assert_select "form[action=?][method=?]", plans_path, "post" do

      assert_select "input[name=?]", "plan[contract_id]"

      assert_select "input[name=?]", "plan[technology_id]"

      assert_select "input[name=?]", "plan[model_gid]"

      assert_select "input[name=?]", "plan[goal]"

      assert_select "input[name=?]", "plan[people_goal]"
    end
  end
end
