require 'rails_helper'

RSpec.describe 'Entry', type: :system do
  let(:live) { create(:live, :draft) }
  let(:user) { create(:user) }

  describe 'list' do
    let!(:entries) { create_list(:song, 10, :draft, live: live) }
    let!(:user_entry) { create(:song, :draft, name: 'applied song', live: live, users: [user, create(:user)]) }

    it 'enables logged-in users to see individual live entries pages and their applied songs' do
      log_in_as user
      visit root_path
      click_link live.name

      expect(page).to have_title(live.title)
      expect(page).to have_content(live.name)
      expect(page).to have_link(t('views.lives.entry'), href: new_live_entry_path(live))
      expect(page).not_to have_css('#admin-tools')
      expect(page).to have_content(user_entry.name)
      user_entry.playings.each do |playing|
        expect(page).to have_content(playing.handle)
      end
      entries.each do |entry|
        expect(page).not_to have_content(entry.name)
      end
    end

    it 'enables admin users to see individual live entries pages and all applied songs' do
      log_in_as create(:admin)
      visit live_entries_path(live)

      expect(page).to have_title(live.title)
      expect(page).to have_link(t('views.lives.entry'), href: new_live_entry_path(live))
      expect(page).to have_css('#admin-tools')
      live.songs.each do |entry|
        expect(page).to have_content(entry.name)
      end
    end
  end

  describe 'add' do
    let!(:users) { create_list(:user, 5) }

    before do
      ActionMailer::Base.deliveries.clear
      log_in_as user
    end

    it 'enables logged-in users to create new entries', js: true do
      visit new_live_entry_path(live)

      expect(page).to have_title('Entry')
      expect(page).to have_content('Entry')

      2.times do
        click_button 'add-member'
      end
      click_button class: 'remove-member', match: :first

      fill_in 'song_name', with: 'テストソング'
      fill_in 'song_artist', with: 'テストアーティスト'
      select 'サークル内', from: 'song_status'

      [user, users.first].each_with_index do |user, i|
        all('.inst-field')[i].set('Gt')
        all('.user-select')[i].find(:option, user.name_with_handle).select_option
      end

      fill_in 'entry_preferred_rehearsal_time', with: '23時以前'
      fill_in 'entry_preferred_performance_time', with: '20時以降'

      accept_confirm do
        click_button t('views.application.send')
      end

      expect(page).to have_css('.alert-success')
      expect(ActionMailer::Base.deliveries.size).to eq 1
    end
  end

  describe 'publish' do
    let(:tweet_job) { class_spy(TweetJob) }

    before do
      stub_const('TweetJob', tweet_job)

      log_in_as create(:admin)
    end

    it 'enables admin users to publish live', elasticsearch: true do
      visit live_entries_path(live)

      click_link t('views.lives.publish')

      expect(tweet_job).to have_received(:perform_now)
      expect(live.reload.published).to be true
      expect(live.published_at).to be_present
      expect(page).to have_css('.alert-success')
    end
  end
end
