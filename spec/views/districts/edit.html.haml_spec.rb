# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "districts/edit", type: :view do
  before(:each) do
    @district = assign(:district, District.create!(
      :name => "MyString",
      :gis_id => 1,
      :latitude => 1.5,
      :longitude => 1.5,
      :population => 1,
      :households => 1
    ))
  end

  it "renders the edit district form" do
    render

    assert_select "form[action=?][method=?]", district_path(@district), "post" do

      assert_select "input[name=?]", "district[name]"

      assert_select "input[name=?]", "district[gis_id]"

      assert_select "input[name=?]", "district[latitude]"

      assert_select "input[name=?]", "district[longitude]"

      assert_select "input[name=?]", "district[population]"

      assert_select "input[name=?]", "district[households]"
    end
  end
end
