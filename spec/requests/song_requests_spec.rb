require 'rails_helper'

RSpec.describe 'Song requests', type: :request do
  describe 'GET /songs' do
    it 'responds 200' do
      get songs_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /songs/search' do
    context 'with valid params' do
      let(:search_params) { { artist: 'The Beatles' } }

      it 'responds 200' do
        get search_songs_path, params: search_params
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid params' do
      let(:search_params) { { video: 'invalid' } }

      it 'responds 422' do
        get search_songs_path, params: search_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  context 'GET /songs/:id' do
    let(:song) { create(:song) }

    it 'responds 200' do
      get search_songs_path(song)
      expect(response).to have_http_status(:ok)
    end
  end

  context 'GET /songs/:id/watch' do
    let(:song) { create(:song, status: :secret) }

    context 'with xhr' do
      let(:xhr) { true }

      context 'by a watchable user' do
        before { log_in_as(create(:user, songs: [song]), capybara: false) }

        it 'responds 200' do
          get watch_song_path(song), xhr: xhr
          expect(response).to have_http_status(:ok)
        end
      end
    end

    context 'without xhr' do
      let(:xhr) { false }

      it 'redirects to /songs/:id' do
        get watch_song_path(song), xhr: xhr
        expect(response).to redirect_to(song_url(song))
      end
    end
  end

  describe 'GET /songs/new' do
    let(:live) { create(:live) }
    context 'by an admin user' do
      before { log_in_as(create(:admin), capybara: false) }

      it 'responds 200' do
        get new_song_path, params: { live_id: live.id }
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'GET /songs/:id/edit' do
    let(:song) { create(:song) }

    context 'by an editable user' do
      before { log_in_as(create(:user, songs: [song]), capybara: false) }

      it 'responds 200' do
        get edit_song_path(song)
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'POST /songs' do
    let(:live) { create(:live) }

    context 'by an admin user' do
      before { log_in_as(create(:admin), capybara: false) }

      context 'with valid params' do
        let(:song_attrs) { attributes_for(:song, live_id: live.id) }

        it 'creates a song and redirects to /song/:id' do
          expect { post songs_path, params: { song: song_attrs } }.to change(Song, :count).by(1)
          expect(response).to redirect_to(Song.last.live)
        end
      end

      context 'with invalid params' do
        let(:song_attrs) { attributes_for(:song, :invalid, live_id: live.id) }

        it 'responds 422' do
          expect { post songs_path, params: { song: song_attrs } }.not_to change(Song, :count)
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end

  describe 'PATCH /songs/:id' do
    let(:song) { create(:song) }

    context 'by an editable user' do
      before { log_in_as(create(:user, songs: [song]), capybara: false) }

      context 'with valid params' do
        let(:new_song_attrs) { attributes_for(:song, name: 'updated song') }

        it 'updates the song and redirects to /songs/:id' do
          patch song_path(song), params: { song: new_song_attrs }
          expect(response).to redirect_to(song_url(song))
          expect(song.reload.name).to eq 'updated song'
        end
      end

      context 'with invalid params' do
        let(:new_song_attrs) { attributes_for(:song, name: '') }

        it 'responds 422' do
          patch song_path(song), params: { song: new_song_attrs }
          expect(response).to have_http_status(:unprocessable_entity)
          expect(song.reload.name).not_to eq ''
        end
      end
    end
  end

  describe 'DELETE /songs/:id' do
    let!(:song) { create(:song) }

    context 'by an admin user' do
      before { log_in_as(create(:admin), capybara: false) }

      it 'deletes the song and redirects /lives/:id' do
        expect { delete song_path(song) }.to change(Song, :count).by(-1)
        expect(response).to redirect_to(live_url(song.live))
      end
    end
  end
end
