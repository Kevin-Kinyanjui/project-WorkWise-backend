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

ActiveRecord::Schema[7.0].define(version: 2023_07_20_171432) do
  create_table "applications", force: :cascade do |t|
    t.integer "job_id", null: false
    t.integer "job_seeker_id", null: false
    t.text "cover_letter"
    t.string "resume"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id"], name: "index_applications_on_job_id"
    t.index ["job_seeker_id"], name: "index_applications_on_job_seeker_id"
  end

  create_table "freelance_applications", force: :cascade do |t|
    t.integer "freelance_task_id", null: false
    t.integer "freelancer_id", null: false
    t.text "proposal"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["freelance_task_id"], name: "index_freelance_applications_on_freelance_task_id"
    t.index ["freelancer_id"], name: "index_freelance_applications_on_freelancer_id"
  end

  create_table "freelance_tasks", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "jobs", force: :cascade do |t|
    t.integer "employer_id", null: false
    t.string "title", null: false
    t.text "description"
    t.text "requirements"
    t.string "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employer_id"], name: "index_jobs_on_employer_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username", null: false
    t.string "email", null: false
    t.string "password", null: false
    t.string "role", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "applications", "jobs"
  add_foreign_key "applications", "users", column: "job_seeker_id"
  add_foreign_key "freelance_applications", "freelance_tasks"
  add_foreign_key "freelance_applications", "users", column: "freelancer_id"
  add_foreign_key "jobs", "users", column: "employer_id"
end
