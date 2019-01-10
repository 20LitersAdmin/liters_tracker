# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "villages/show", type: :view do
  before(:each) do
    @village = assign(:village, Village.create!(
      :name => "Name",
      :gis_id => 2,
      :latitude => 3.5,
      :longitude => 4.5,
      :population => 5,
      :households => 6
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3.5/)
    expect(rendered).to match(/4.5/)
    expect(rendered).to match(/5/)
    expect(rendered).to match(/6/)
  end
end
