# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "cells/edit", type: :view do
  before(:each) do
    @cell = assign(:cell, Cell.create!(
      :name => "MyString",
      :gis_id => 1,
      :latitude => 1.5,
      :longitude => 1.5,
      :population => 1,
      :households => 1
    ))
  end

  it "renders the edit cell form" do
    render

    assert_select "form[action=?][method=?]", cell_path(@cell), "post" do

      assert_select "input[name=?]", "cell[name]"

      assert_select "input[name=?]", "cell[gis_id]"

      assert_select "input[name=?]", "cell[latitude]"

      assert_select "input[name=?]", "cell[longitude]"

      assert_select "input[name=?]", "cell[population]"

      assert_select "input[name=?]", "cell[households]"
    end
  end
end
