class CreateDefinitions < ActiveRecord::Migration[7.2]
  def change
    create_table :definitions do |t|

      t.timestamps
    end
  end
end
