class DnsRecord < ApplicationRecord
  belongs_to :domain
  belongs_to :record
end
