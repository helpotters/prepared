class CreateDefinitions < ActiveRecord::Migration[7.0]
  def change
    create_table "definitions", force: :cascade do |t|
      t.string "definition"
      t.string "example_sentence"
      t.bigint "word_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    add_index "definitions", ["word_id"], name: "index_definitions_on_word_id"
    add_foreign_key "definitions", "words"
  end
end
