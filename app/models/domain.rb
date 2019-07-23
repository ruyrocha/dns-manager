class Domain < ApplicationRecord
    validates :name, presence: true, uniqueness: true

    has_many :records
end
