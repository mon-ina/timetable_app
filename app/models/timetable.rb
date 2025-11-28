class Timetable < ApplicationRecord
  belongs_to :subject, optional: true
end
