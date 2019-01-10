# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "targets/edit", type: :view do
  before(:each) do
    @target = assign(:target, Target.create!(
      :contract => nil,
      :technology => nil,
      :goal => 1,
      :people_goal => 1
    ))
  end

  it "renders the edit target form" do
    render

    assert_select "form[action=?][method=?]", target_path(@target), "post" do

      assert_select "input[name=?]", "target[contract_id]"

      assert_select "input[name=?]", "target[technology_id]"

      assert_select "input[name=?]", "target[goal]"

      assert_select "input[name=?]", "target[people_goal]"
    end
  end
end
