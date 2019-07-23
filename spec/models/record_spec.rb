require 'rails_helper'

RSpec.describe Record, type: :model do
  it { is_expected.to validate_presence_of(:value) }
  it { is_expected.to validate_uniqueness_of(:value) }
  it { is_expected.to have_many(:dns_records) }
  it { is_expected.to have_many(:domains).through(:dns_records) }
end
