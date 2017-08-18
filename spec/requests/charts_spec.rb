require 'rails_helper'

RSpec.describe "Charts", type: :request do
  describe "GET /charts" do
    it "works! (now write some real specs)" do
      get charts_path
      expect(response).to have_http_status(200)
    end
  end
end
