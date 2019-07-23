FactoryBot.define do
  factory :record do
    name { "MyString" }
    record_type { 1 }
    ttl { 1 }
    value { "MyText" }
  end
end
