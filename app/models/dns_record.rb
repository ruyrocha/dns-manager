class DnsRecord < ApplicationRecord
  belongs_to :domain
  belongs_to :record

  scope :matching_records, -> (included_ips = nil, excluded_ips = nil) {
    ips = if included_ips && excluded_ips
            included_ips - excluded_ips
          else
            included_ips.presence || excluded_ips.presence
          end

    joins(:domain, :record)
      .where(records: { value: ips })
      .pluck("records.id", "domains.name", "records.value")
  }
end
