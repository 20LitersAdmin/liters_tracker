# frozen_string_literal: true

require "rails_helper"

RSpec.describe VillagesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/villages").to route_to("villages#index")
    end

    it "routes to #new" do
      expect(:get => "/villages/new").to route_to("villages#new")
    end

    it "routes to #show" do
      expect(:get => "/villages/1").to route_to("villages#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/villages/1/edit").to route_to("villages#edit", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/villages").to route_to("villages#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/villages/1").to route_to("villages#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/villages/1").to route_to("villages#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/villages/1").to route_to("villages#destroy", :id => "1")
    end
  end
end
