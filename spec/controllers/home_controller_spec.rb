require 'rails_helper'

RSpec.describe HomeController, type: :controller do

  describe "GET #index" do
    before { get :index }
    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "shows the right content" do
      expect(JSON.parse(response.body)).to eq({ "message" => "Hello." })
    end
  end
end
