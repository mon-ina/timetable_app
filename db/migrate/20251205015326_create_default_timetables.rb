class CreateDefaultTimetables < ActiveRecord::Migration[8.0]
  def change
    create_table :default_timetables do |t|
      t.integer :grade
      t.integer :semester
      t.integer :day_of_week
      t.integer :period
      t.references :subject, null: false, foreign_key: true

      t.timestamps
    end

    add_index :default_timetables, [:grade, :semester, :day_of_week, :period], unique: true, name: 'index_default_timetables_unique'
  end
end
