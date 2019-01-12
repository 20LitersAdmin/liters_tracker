# frozen_string_literal: true

require "rails_helper"

RSpec.describe UpdatesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/updates").to route_to("updates#index")
    end

    it "routes to #new" do
      expect(:get => "/updates/new").to route_to("updates#new")
    end

    it "routes to #show" do
      expect(:get => "/updates/1").to route_to("updates#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/updates/1/edit").to route_to("updates#edit", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/updates").to route_to("updates#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/updates/1").to route_to("updates#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/updates/1").to route_to("updates#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/updates/1").to route_to("updates#destroy", :id => "1")
    end
  end
end
