# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "villages/edit", type: :view do
  before(:each) do
    @village = assign(:village, Village.create!(
      :name => "MyString",
      :gis_id => 1,
      :latitude => 1.5,
      :longitude => 1.5,
      :population => 1,
      :households => 1
    ))
  end

  it "renders the edit village form" do
    render

    assert_select "form[action=?][method=?]", village_path(@village), "post" do

      assert_select "input[name=?]", "village[name]"

      assert_select "input[name=?]", "village[gis_id]"

      assert_select "input[name=?]", "village[latitude]"

      assert_select "input[name=?]", "village[longitude]"

      assert_select "input[name=?]", "village[population]"

      assert_select "input[name=?]", "village[households]"
    end
  end
end
