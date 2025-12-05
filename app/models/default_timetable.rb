class DefaultTimetable < ApplicationRecord
  belongs_to :subject, optional: true
  
  validates :grade, presence: true, inclusion: { in: [1, 2] }
  validates :semester, presence: true, inclusion: { in: [1, 2] } # 1: 前期, 2: 後期
  validates :day_of_week, presence: true, inclusion: { in: 1..5 }
  validates :period, presence: true, inclusion: { in: 1..3 }
end