class Domain < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  has_many :dns_records
  has_many :records, through: :dns_records
end
