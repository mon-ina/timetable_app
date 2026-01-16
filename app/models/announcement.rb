class Announcement < ApplicationRecord
    has_many :announcement_reads, dependent: :destroy
    
    validates :title, presence: true, length: { maximum: 100 }
    validates :content, presence: true, length: { maximum: 1000 }
    validates :grade, presence: true, inclusion: { in: [1, 2] }
    validates :published_at, presence: true
    
    scope :for_grade, ->(grade) { where(grade: grade) }
    scope :recent_first, -> { order(published_at: :desc) }
    
    # 特定のセッションIDで既読かどうか
    def read_by?(session_id)
      announcement_reads.exists?(student_session_id: session_id)
    end
    
    # 既読にする
    def mark_as_read!(session_id)
      announcement_reads.find_or_create_by!(student_session_id: session_id) do |read|
        read.read_at = Time.current
      end
    end
  end