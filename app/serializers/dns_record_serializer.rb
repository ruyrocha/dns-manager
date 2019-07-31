class DnsRecordSerializer < BaseSerializer
  attribute :id

  attribute :hostname do |_|
    _&.domain&.name
  end

  attribute :ip_address do |_|
    _&.record&.value
  end
end
