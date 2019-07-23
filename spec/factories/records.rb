FactoryBot.define do
  factory :record do
    record_type { Record.record_types[:a] }
    value       { FFaker::Internet.ip_v4_address }
  end
end
