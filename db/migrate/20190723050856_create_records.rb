class CreateRecords < ActiveRecord::Migration[5.2]
  def change
    create_table :records do |t|
      t.string :name
      t.integer :record_type, null: false, default: 0
      t.integer :ttl, null: false, default: 300
      t.text :value

      t.timestamps
    end

    add_index :records, :value
  end
end
