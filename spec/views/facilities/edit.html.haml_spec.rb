# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "facilities/edit", type: :view do
  before(:each) do
    @facility = assign(:facility, Facility.create!(
      :name => "MyString",
      :gis_id => 1,
      :latitude => 1.5,
      :longitude => 1.5,
      :population => 1,
      :households => 1,
      :category => "MyString"
    ))
  end

  it "renders the edit facility form" do
    render

    assert_select "form[action=?][method=?]", facility_path(@facility), "post" do

      assert_select "input[name=?]", "facility[name]"

      assert_select "input[name=?]", "facility[gis_id]"

      assert_select "input[name=?]", "facility[latitude]"

      assert_select "input[name=?]", "facility[longitude]"

      assert_select "input[name=?]", "facility[population]"

      assert_select "input[name=?]", "facility[households]"

      assert_select "input[name=?]", "facility[category]"
    end
  end
end
