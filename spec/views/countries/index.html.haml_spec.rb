require 'rails_helper'

RSpec.describe "countries/index", type: :view do
  before(:each) do
    assign(:countries, [
      Country.create!(
        :name => "Name",
        :gis_code => 2,
        :latitude => 3.5,
        :longitude => 4.5,
        :population => 5,
        :households => 6
      ),
      Country.create!(
        :name => "Name",
        :gis_code => 2,
        :latitude => 3.5,
        :longitude => 4.5,
        :population => 5,
        :households => 6
      )
    ])
  end

  it "renders a list of countries" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.5.to_s, :count => 2
    assert_select "tr>td", :text => 4.5.to_s, :count => 2
    assert_select "tr>td", :text => 5.to_s, :count => 2
    assert_select "tr>td", :text => 6.to_s, :count => 2
  end
end
