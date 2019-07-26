require 'resolv'

class IPV4Address < Grape::Validations::Base
  def validate_param!(attr_name, params)
    unless Resolv::IPv4::Regex.match(params[attr_name])
      raise Grape::Exceptions::Validation,
        params: [@scope.full_name(attr_name)],
        message: "Invalid IPv4 address."
    end
  end
end
