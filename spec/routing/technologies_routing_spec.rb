# frozen_string_literal: true

require "rails_helper"

RSpec.describe TechnologiesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/technologies").to route_to("technologies#index")
    end

    it "routes to #new" do
      expect(:get => "/technologies/new").to route_to("technologies#new")
    end

    it "routes to #show" do
      expect(:get => "/technologies/1").to route_to("technologies#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/technologies/1/edit").to route_to("technologies#edit", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/technologies").to route_to("technologies#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/technologies/1").to route_to("technologies#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/technologies/1").to route_to("technologies#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/technologies/1").to route_to("technologies#destroy", :id => "1")
    end
  end
end
