require 'rails_helper'

RSpec.describe 'Song', type: :system do
  describe 'list' do
    before { create_list(:song, Song.per_page + 1) }

    it 'enables users to see the first page of the published songs and move to the next page' do
      visit songs_path

      expect(page).to have_title('Song Search')
      expect(page).to have_content('Song Search')
      Song.published.order_by_live.page(1).each do |song|
        expect(page).to have_content(song.name)
      end
      Song.published.order_by_live.page(2).each do |song|
        expect(page).not_to have_content(song.name)
      end

      click_link '2'

      Song.published.order_by_live.page(2).each do |song|
        expect(page).to have_content(song.name)
      end
    end
  end

  describe 'search' do
    let!(:beatles_song) { create(:song, artist: 'The Beatles') }

    before { Song.__elasticsearch__.refresh_index! }

    it 'enables users to search songs from the both of basic and advanced forms', js: true, elasticsearch: true do
      visit songs_path

      fill_in 'q', with: 'The Beatles'
      click_button 'Search'

      expect(page).to have_content(beatles_song.name)

      click_on 'Advanced'
      fill_in 'artist', with: 'The Beatles'
      click_button 'Search'

      expect(page).to have_content(beatles_song.name)

      fill_in 'name', with: 'No results'
      click_button 'Search'

      expect(page).not_to have_content(beatles_song.name)
      expect(page).to have_css('.alert-danger')
    end
  end

  describe 'detail' do
    let(:song) { create(:song, users: create_list(:user, 2)) }

    it 'enables users to see individual songs' do
      visit song_path(song)

      expect(page).to have_title(song.title)
      expect(page).to have_content(song.name)
      expect(page).to have_content(song.artist)
      expect(page).to have_content(song.live_name)
      expect(page).to have_content(song.time_order)
      song.playings.each do |playing|
        expect(page).to have_content(playing.handle)
      end
    end
  end

  describe 'add' do
    let(:live) { create(:live) }
    let!(:user1) { create(:user, nickname: '一郎') }
    let!(:user2) { create(:user, nickname: '二郎') }

    before { log_in_as create(:admin) }

    it 'enables admin users to create new songs', js: true do
      visit live_path(live)

      click_link 'Add song'

      expect(page).to have_title('Add Song')
      expect(page).to have_content('Add Song')

      fill_in 'song_order', with: '1'
      fill_in 'song_name', with: 'テストソング'
      fill_in 'song_artist', with: 'テストアーティスト'

      click_button 'add-member'
      click_button 'add-member'
      click_button class: 'remove-member', match: :first

      [user1, user2].each_with_index do |user, i|
        all('.inst-field')[i].set('Gt')
        all('.user-select')[i].find(:option, user.name_with_handle).select_option
      end

      expect { click_button 'Add' }.to change(Song, :count).by(1)
      expect(page).to have_css('.alert-success')
    end
  end

  describe 'edit' do
    let(:user) { create(:user) }
    let(:song) { create(:song, users: [user]) }

    it 'enables admin users to update songs' do
      log_in_as create(:admin)

      visit song_path(song)
      click_link 'Edit'

      expect(page).to have_title('Edit Song')
      expect(page).to have_content('Edit Song')

      fill_in 'song_youtube_id', with: 'https://www.youtube.com/watch?v=new_youtube'
      click_button 'Save'

      expect(page).to have_css('.alert-success')
      expect(song.reload.youtube_id).to eq 'new_youtube'
    end

    it 'enables logged-in users to update songs they played' do
      log_in_as user

      visit song_path(song)
      click_link 'Edit'

      expect(page).to have_title('Edit Song')
      expect(page).to have_content('Edit Song')

      select '公開', from: 'song_status'
      fill_in 'song_comment', with: 'お気に入りの曲です'
      click_button 'Save'

      expect(page).to have_css('.alert-success')
      expect(song.reload.status).to eq 'open'
      expect(song.comment).to eq 'お気に入りの曲です'
    end
  end

  describe 'delete' do
    let(:song) { create(:song) }

    before { log_in_as create(:admin) }

    it 'enables admin users to delete songs' do
      visit song_path(song)
      click_link 'Edit'

      expect { click_link('Delete') }.to change(Song, :count).by(-1)
    end
  end
end
