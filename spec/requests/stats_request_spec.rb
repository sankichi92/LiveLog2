require 'rails_helper'

RSpec.describe 'stats request:', type: :request do
  before { create_list(:live, 5, :with_songs) }

  describe 'GET /stats/:year' do
    context "with year = 'current'" do
      let(:year) { 'current' }

      it 'redirects /stats/{Live.pubhlishde.years.first}' do
        get stat_path(year)
        expect(response).to redirect_to(stat_path(Live.published.years.first))
      end
    end

    context 'with valid year' do
      let(:year) { Live.published.years.first }

      it 'responds 200' do
        get stat_path(year)
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid year' do
      let(:year) { Live.published.years.last - 1 }

      it 'raise ActionController::RoutingError' do
        expect { get stat_path(year) }.to raise_error ActionController::RoutingError
      end
    end
  end
end
