# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "plans/edit", type: :view do
  before(:each) do
    @plan = assign(:plan, Plan.create!(
      :contract => nil,
      :technology => nil,
      :model_gid => "MyString",
      :goal => 1,
      :people_goal => 1
    ))
  end

  it "renders the edit plan form" do
    render

    assert_select "form[action=?][method=?]", plan_path(@plan), "post" do

      assert_select "input[name=?]", "plan[contract_id]"

      assert_select "input[name=?]", "plan[technology_id]"

      assert_select "input[name=?]", "plan[model_gid]"

      assert_select "input[name=?]", "plan[goal]"

      assert_select "input[name=?]", "plan[people_goal]"
    end
  end
end
