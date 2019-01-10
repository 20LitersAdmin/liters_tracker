# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "updates/new", type: :view do
  before(:each) do
    assign(:update, Update.new(
      :technology => nil,
      :distributed => 1,
      :checked => 1,
      :user => nil,
      :model_gid => "MyString",
      :distribute => 1,
      :check => 1
    ))
  end

  it "renders new update form" do
    render

    assert_select "form[action=?][method=?]", updates_path, "post" do

      assert_select "input[name=?]", "update[technology_id]"

      assert_select "input[name=?]", "update[distributed]"

      assert_select "input[name=?]", "update[checked]"

      assert_select "input[name=?]", "update[user_id]"

      assert_select "input[name=?]", "update[model_gid]"

      assert_select "input[name=?]", "update[distribute]"

      assert_select "input[name=?]", "update[check]"
    end
  end
end
