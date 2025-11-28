class AddColumnToTimetable < ActiveRecord::Migration[8.0]
  def change
    add_column :timetables, :base_subject, :boolean
  end
end
