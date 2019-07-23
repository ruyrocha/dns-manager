require 'rails_helper'

RSpec.describe Record, type: :model do
  it { is_expected.to validate_presence_of(:value) }
end
