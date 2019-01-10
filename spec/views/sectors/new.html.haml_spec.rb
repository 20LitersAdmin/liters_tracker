# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "sectors/new", type: :view do
  before(:each) do
    assign(:sector, Sector.new(
      :name => "MyString",
      :gis_id => 1,
      :latitude => 1.5,
      :longitude => 1.5,
      :population => 1,
      :households => 1
    ))
  end

  it "renders new sector form" do
    render

    assert_select "form[action=?][method=?]", sectors_path, "post" do

      assert_select "input[name=?]", "sector[name]"

      assert_select "input[name=?]", "sector[gis_id]"

      assert_select "input[name=?]", "sector[latitude]"

      assert_select "input[name=?]", "sector[longitude]"

      assert_select "input[name=?]", "sector[population]"

      assert_select "input[name=?]", "sector[households]"
    end
  end
end
