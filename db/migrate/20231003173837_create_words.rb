class CreateWords < ActiveRecord::Migration[7.0]
  def change
    create_table :words do |t|
      t.string :word, null: false
      t.string :part_of_speech

      t.index :word
      t.timestamps
    end
  end
end
