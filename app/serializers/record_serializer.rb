class RecordSerializer < ActiveModel::Serializer
  attribute :id
  attribute :type
  attribute :value

  attribute :domains do
    object.domains.count
  end

  def type
    object.record_type.upcase
  end
end
