# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "targets/new", type: :view do
  before(:each) do
    assign(:target, Target.new(
      :contract => nil,
      :technology => nil,
      :goal => 1,
      :people_goal => 1
    ))
  end

  it "renders new target form" do
    render

    assert_select "form[action=?][method=?]", targets_path, "post" do

      assert_select "input[name=?]", "target[contract_id]"

      assert_select "input[name=?]", "target[technology_id]"

      assert_select "input[name=?]", "target[goal]"

      assert_select "input[name=?]", "target[people_goal]"
    end
  end
end
