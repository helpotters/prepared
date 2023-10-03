class CreateDefinitions < ActiveRecord::Migration[7.0]
  def change
    create_table :definitions, force: :cascade do |t|
      t.belongs_to :word, index: { unique: true }, foreign_key: true
      t.string :definition
      t.string :example_sentence

      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
