# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_01_09_030523) do
  create_table "announcement_reads", force: :cascade do |t|
    t.integer "announcement_id", null: false
    t.string "student_session_id", null: false
    t.datetime "read_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["announcement_id", "student_session_id"], name: "index_announcement_reads_unique", unique: true
    t.index ["announcement_id"], name: "index_announcement_reads_on_announcement_id"
  end

  create_table "announcements", force: :cascade do |t|
    t.string "title", null: false
    t.text "content", null: false
    t.integer "grade", null: false
    t.datetime "published_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["grade", "published_at"], name: "index_announcements_on_grade_and_published_at"
  end

  create_table "default_timetables", force: :cascade do |t|
    t.integer "grade"
    t.integer "semester"
    t.integer "day_of_week"
    t.integer "period"
    t.integer "subject_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["grade", "semester", "day_of_week", "period"], name: "index_default_timetables_unique", unique: true
    t.index ["subject_id"], name: "index_default_timetables_on_subject_id"
  end

  create_table "subjects", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "timetables", force: :cascade do |t|
    t.integer "subject_id"
    t.date "week_start_date"
    t.integer "day_of_week"
    t.integer "period"
    t.integer "grade"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "base_subject"
    t.index ["subject_id"], name: "index_timetables_on_subject_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "account_name"
    t.string "password_digest"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "announcement_reads", "announcements"
  add_foreign_key "default_timetables", "subjects"
  add_foreign_key "timetables", "subjects"
end
