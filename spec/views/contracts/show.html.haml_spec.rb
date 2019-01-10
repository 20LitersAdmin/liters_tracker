# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "contracts/show", type: :view do
  before(:each) do
    @contract = assign(:contract, Contract.create!(
      :budget => "",
      :household_goal => 2,
      :people_goal => 3
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
  end
end
