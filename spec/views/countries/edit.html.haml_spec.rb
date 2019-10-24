require 'rails_helper'

RSpec.describe "countries/edit", type: :view do
  before(:each) do
    @country = assign(:country, Country.create!(
      :name => "MyString",
      :gis_code => 1,
      :latitude => 1.5,
      :longitude => 1.5,
      :population => 1,
      :households => 1
    ))
  end

  it "renders the edit country form" do
    render

    assert_select "form[action=?][method=?]", country_path(@country), "post" do

      assert_select "input[name=?]", "country[name]"

      assert_select "input[name=?]", "country[gis_code]"

      assert_select "input[name=?]", "country[latitude]"

      assert_select "input[name=?]", "country[longitude]"

      assert_select "input[name=?]", "country[population]"

      assert_select "input[name=?]", "country[households]"
    end
  end
end
