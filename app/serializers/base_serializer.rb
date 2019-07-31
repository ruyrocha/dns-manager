class BaseSerializer < ActiveModel::Serializer
  include FastJsonapi::ObjectSerializer
end
