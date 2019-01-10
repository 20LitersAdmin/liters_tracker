# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "targets/show", type: :view do
  before(:each) do
    @target = assign(:target, Target.create!(
      :contract => nil,
      :technology => nil,
      :goal => 2,
      :people_goal => 3
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
  end
end
