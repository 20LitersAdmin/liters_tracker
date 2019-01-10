# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "contracts/new", type: :view do
  before(:each) do
    assign(:contract, Contract.new(
      :budget => "",
      :household_goal => 1,
      :people_goal => 1
    ))
  end

  it "renders new contract form" do
    render

    assert_select "form[action=?][method=?]", contracts_path, "post" do

      assert_select "input[name=?]", "contract[budget]"

      assert_select "input[name=?]", "contract[household_goal]"

      assert_select "input[name=?]", "contract[people_goal]"
    end
  end
end
