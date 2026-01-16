class CreateAnnouncements < ActiveRecord::Migration[8.0]
  def change
    create_table :announcements do |t|
      t.string :title, null: false
      t.text :content, null: false
      t.integer :grade, null: false  # 1年生 or 2年生
      t.datetime :published_at, null: false
      
      t.timestamps
    end
    
    add_index :announcements, [:grade, :published_at]
    
    # 既読管理テーブル
    create_table :announcement_reads do |t|
      t.references :announcement, null: false, foreign_key: true
      t.string :student_session_id, null: false  # セッションIDで生徒を識別
      t.datetime :read_at, null: false
      
      t.timestamps
    end
    
    add_index :announcement_reads, [:announcement_id, :student_session_id], 
              unique: true, 
              name: 'index_announcement_reads_unique'
  end
end