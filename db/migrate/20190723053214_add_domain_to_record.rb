class AddDomainToRecord < ActiveRecord::Migration[5.2]
  def change
    add_reference :records, :domain, foreign_key: true
  end
end
