class Record < ApplicationRecord
  enum record_type: {
    a: 0,
    aaaa: 1,
    alias: 2,
    cname: 3,
    mx: 4,
    ns: 5,
    ptr: 6,
    ns: 7,
    ptr: 8,
    soa: 9,
    srv: 10,
    txt: 11
  }

  validates :value, presence: true, uniqueness: true

  has_many :dns_records
  has_many :domains, through: :dns_records
end
