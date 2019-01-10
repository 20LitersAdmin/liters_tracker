# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "sectors/edit", type: :view do
  before(:each) do
    @sector = assign(:sector, Sector.create!(
      :name => "MyString",
      :gis_id => 1,
      :latitude => 1.5,
      :longitude => 1.5,
      :population => 1,
      :households => 1
    ))
  end

  it "renders the edit sector form" do
    render

    assert_select "form[action=?][method=?]", sector_path(@sector), "post" do

      assert_select "input[name=?]", "sector[name]"

      assert_select "input[name=?]", "sector[gis_id]"

      assert_select "input[name=?]", "sector[latitude]"

      assert_select "input[name=?]", "sector[longitude]"

      assert_select "input[name=?]", "sector[population]"

      assert_select "input[name=?]", "sector[households]"
    end
  end
end
