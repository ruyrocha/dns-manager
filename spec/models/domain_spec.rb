require 'rails_helper'

RSpec.describe Domain, type: :model do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }
  it { is_expected.to have_many(:dns_records) }
  it { is_expected.to have_many(:records).through(:dns_records) }
end
