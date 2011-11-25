class NetsuiteResult
  attr_accessor :response

  def initialize(response)
    @response = response
  end

  def success?
    response.status.xmlattr_isSuccess
  end

  def base_id
    response.baseRef.xmlattr_internalId.to_i rescue nil
  end
  alias :internal_id :base_id

  def external_id
    response.baseRef.xmlattr_externalId rescue nil
  end

  def error_message
    response.status.statusDetail[0].message if !success?
  end

  def error_code
    response.status.statusDetail[0].code if !success?
  end
end
