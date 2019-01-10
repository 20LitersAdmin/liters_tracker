# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "technologies/show", type: :view do
  before(:each) do
    @technology = assign(:technology, Technology.create!(
      :name => "Name",
      :default_impact => 2,
      :agreement_required => false,
      :scale => "Scale",
      :direct_cost => "",
      :indirect_cost => "",
      :us_cost => "",
      :local_cost => ""
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/Scale/)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
  end
end
