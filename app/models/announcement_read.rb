class AnnouncementRead < ApplicationRecord
    belongs_to :announcement
    
    validates :student_session_id, presence: true
    validates :read_at, presence: true
    validates :announcement_id, uniqueness: { scope: :student_session_id }
end