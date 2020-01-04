class Entry < ApplicationRecord
  belongs_to :song
  belongs_to :member
  has_many :playable_times, dependent: :delete_all

  accepts_nested_attributes_for :playable_times, allow_destroy: true

  validates :playable_times, presence: true
  validates_associated :song
  validate :live_must_be_unpublished

  scope :submitted_or_played_by, ->(member) do
    joins(song: { plays: :member }).merge(Member.where(id: member.id))
      .or(joins(song: { plays: :member }).where(member_id: member.id))
  end

  def submitter?(user)
    member_id == user.member_id
  end

  private

  # region Validations

  def live_must_be_unpublished
    errors.add(:base, 'エントリー募集中のライブではありません') if song.live.published?
  end

  # endregion
end
