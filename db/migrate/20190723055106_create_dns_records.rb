class CreateDnsRecords < ActiveRecord::Migration[5.2]
  def change
    create_table :dns_records do |t|
      t.integer :domain_id
      t.integer :record_id

      t.timestamps
    end
  end
end
