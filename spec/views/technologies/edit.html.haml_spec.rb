# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "technologies/edit", type: :view do
  before(:each) do
    @technology = assign(:technology, Technology.create!(
      :name => "MyString",
      :default_impact => 1,
      :agreement_required => false,
      :scale => "MyString",
      :direct_cost => "",
      :indirect_cost => "",
      :us_cost => "",
      :local_cost => ""
    ))
  end

  it "renders the edit technology form" do
    render

    assert_select "form[action=?][method=?]", technology_path(@technology), "post" do

      assert_select "input[name=?]", "technology[name]"

      assert_select "input[name=?]", "technology[default_impact]"

      assert_select "input[name=?]", "technology[agreement_required]"

      assert_select "input[name=?]", "technology[scale]"

      assert_select "input[name=?]", "technology[direct_cost]"

      assert_select "input[name=?]", "technology[indirect_cost]"

      assert_select "input[name=?]", "technology[us_cost]"

      assert_select "input[name=?]", "technology[local_cost]"
    end
  end
end
