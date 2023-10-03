class CreateWords < ActiveRecord::Migration[7.0]
  def change
    create_table "words", force: :cascade do |t|
      t.string "word"
      t.string "part_of_speech"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end
  end
end
