# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "technologies/index", type: :view do
  before(:each) do
    assign(:technologies, [
      Technology.create!(
        :name => "Name",
        :default_impact => 2,
        :agreement_required => false,
        :scale => "Scale",
        :direct_cost => "",
        :indirect_cost => "",
        :us_cost => "",
        :local_cost => ""
      ),
      Technology.create!(
        :name => "Name",
        :default_impact => 2,
        :agreement_required => false,
        :scale => "Scale",
        :direct_cost => "",
        :indirect_cost => "",
        :us_cost => "",
        :local_cost => ""
      )
    ])
  end

  it "renders a list of technologies" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => "Scale".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
  end
end
