require "rails_helper"

RSpec.describe ChartsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/charts").to route_to("charts#index")
    end

    it "routes to #new" do
      expect(:get => "/charts/new").to route_to("charts#new")
    end

    it "routes to #show" do
      expect(:get => "/charts/1").to route_to("charts#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/charts/1/edit").to route_to("charts#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/charts").to route_to("charts#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/charts/1").to route_to("charts#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/charts/1").to route_to("charts#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/charts/1").to route_to("charts#destroy", :id => "1")
    end

  end
end
