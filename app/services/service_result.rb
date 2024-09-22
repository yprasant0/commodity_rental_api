class ServiceResult
  attr_reader :success, :data, :error, :error_type

  def initialize(success, data = nil, error = nil, error_type = nil)
    @success = success
    @data = data
    @error = error
    @error_type = error_type
  end

  def self.success(data = nil)
    new(true, data)
  end

  def self.error(error, error_type = nil)
    new(false, nil, error, error_type)
  end
end
