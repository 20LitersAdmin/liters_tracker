# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "contracts/edit", type: :view do
  before(:each) do
    @contract = assign(:contract, Contract.create!(
      :budget => "",
      :household_goal => 1,
      :people_goal => 1
    ))
  end

  it "renders the edit contract form" do
    render

    assert_select "form[action=?][method=?]", contract_path(@contract), "post" do

      assert_select "input[name=?]", "contract[budget]"

      assert_select "input[name=?]", "contract[household_goal]"

      assert_select "input[name=?]", "contract[people_goal]"
    end
  end
end
