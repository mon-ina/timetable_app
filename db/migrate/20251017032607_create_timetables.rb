class CreateTimetables < ActiveRecord::Migration[8.0]
  def change
    create_table :timetables do |t|
      t.references :subject, null: true, foreign_key: true # ← null: true に変更
      t.date :week_start_date
      t.integer :day_of_week
      t.integer :period
      t.integer :grade

      t.timestamps
    end
  end
end
