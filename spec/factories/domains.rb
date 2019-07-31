FactoryBot.define do
  factory :domain do
    name { FFaker::Internet.domain_name }
  end
end
