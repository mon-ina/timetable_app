class ChangeSubjectIdColum < ActiveRecord::Migration[8.0]
  def up
    change_column_null :timetables, :subject_id, true
  end

  def down
    change_column_null :timetables, :subject_id, false
  end
end
