class TimeFormatter

  VALID_FORMATS = ["year", "month", "day", "hour", "minute", "second"]

  def initialize(parameters_string)
    @parameters_string = parameters_string
    format
    @formats
  end

  def format
    @formats = @parameters_string.split(/\W+/)
    @valid_formats = []
    @invalid_formats = []
    @formats.each do |f|
      if VALID_FORMATS.include?(f)
        @valid_formats << f
      else
        @invalid_formats << f
      end
    end
  end

  def get_body_content
    time = Time.now
    body_content = []
    @valid_formats.map! { |vf| vf == "minute" ? "min" : vf }
    @valid_formats.map! { |vf| vf == "second" ? "sec" : vf }
    @valid_formats.each { |vf| body_content << time.instance_eval(vf) }
    body_content = body_content.join("-")
    body_content += "\n"
  end

  def valid?
    @invalid_formats.empty?
  end

  def valid
    @valid_formats
  end

  def invalid
    @invalid_formats
  end

end