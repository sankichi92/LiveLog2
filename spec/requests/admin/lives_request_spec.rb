require 'rails_helper'

RSpec.describe 'admin/lives request:', type: :request do
  let(:admin) { create(:admin) }

  before do
    log_in_as admin
  end

  describe 'GET /admin/lives' do
    before do
      create_pair(:live)
      create_pair(:live, :unpublished)
    end

    it 'responds 200' do
      get admin_lives_path

      expect(response).to have_http_status :ok
    end
  end

  describe 'GET /admin/lives/new' do
    it 'responds 200' do
      get new_admin_live_path

      expect(response).to have_http_status :ok
    end
  end

  describe 'POST /admin/lives' do
    context 'with valid params' do
      let(:params) do
        {
          live: {
            date: date.to_s,
            name: '6月ライブ',
            place: '4共21',
            album_url: '',
          },
        }
      end
      let(:date) { Time.zone.today }

      it 'creates a live and redirects to /admin/lives' do
        expect { post admin_lives_path, params: params }.to change(Live, :count).by(1)

        expect(response).to redirect_to admin_lives_path(year: date.nendo)
      end
    end

    context 'with invalid params' do
      let(:params) do
        {
          live: {
            date: '',
            name: '',
            place: '',
            album_url: '',
          },
        }
      end

      it 'responds 422' do
        expect { post admin_lives_path, params: params }.not_to change(Live, :count)

        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end

  describe 'GET /admin/lives/:id/edit' do
    let(:live) { create(:live) }

    it 'responds 200' do
      get edit_admin_live_path(live)

      expect(response).to have_http_status :ok
    end
  end

  describe 'PATCH /admin/lives/:id' do
    let(:live) { create(:live, album_url: '') }

    context 'with valid params' do
      let(:params) do
        {
          live: {
            date: live.date.to_s,
            name: live.name,
            place: live.place,
            album_url: new_album_url,
          },
        }
      end
      let(:new_album_url) { 'https://goo.gl/photos/album' }

      it 'updates the live and redirects to /admin/lives' do
        patch admin_live_path(live), params: params

        expect(live.reload.album_url).to eq new_album_url
        expect(response).to redirect_to admin_lives_path(year: live.date.nendo)
      end
    end

    context 'with invalid params' do
      let(:params) do
        {
          live: {
            date: live.date.to_s,
            name: invalid_name,
            place: live.place,
            album_url: live.album_url,
          },
        }
      end
      let(:invalid_name) { 'a' * 21 }

      it 'responds 422' do
        patch admin_live_path(live), params: params

        expect(live.reload.name).not_to eq invalid_name
        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end

  describe 'DELETE /admin/lives/:id' do
    let(:live) { create(:live) }

    it 'destroys the live and redirects to /admin/lives' do
      delete admin_live_path(live)

      expect(response).to redirect_to admin_lives_path(year: live.date.nendo)
      expect { live.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe 'PUT /admin/lives/:id/publish' do
    let(:live) { create(:live, :unpublished) }

    it 'publishes the live and redirects to /admin/lives' do
      put publish_admin_live_path(live)

      expect(live.reload).to be_published
      expect(response).to redirect_to admin_lives_path(year: live.date.nendo)
    end
  end
end