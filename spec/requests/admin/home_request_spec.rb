require 'rails_helper'

RSpec.describe 'admin/home requests:', type: :request do
  let(:admin) { create(:admin) }

  before do
    log_in_as admin
  end

  describe 'GET /admin' do
    it 'responds 200' do
      get admin_root_path

      expect(response).to have_http_status :ok
    end
  end
end