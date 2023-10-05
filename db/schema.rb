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

ActiveRecord::Schema[7.2].define(version: 2023_10_03_173922) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "definitions", force: :cascade do |t|
    t.bigint "word_id"
    t.string "definition"
    t.string "example_sentence"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["word_id"], name: "index_definitions_on_word_id"
  end

  create_table "words", force: :cascade do |t|
    t.string "word", null: false
    t.string "part_of_speech"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["word"], name: "index_words_on_word"
  end

  add_foreign_key "definitions", "words"
end
