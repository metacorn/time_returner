require 'rack'
require 'byebug'

class TimeReturner
  TRAILING_SLASHES_PATTERN = /\/+$/
  VALID_QUERY_PATTERN = /^(format=)/
  VALID_FORMATS = ["year", "month", "day", "hour", "minute", "second"]

  def call(env)
    method = env["REQUEST_METHOD"]
    path_info = env["PATH_INFO"]
    query_string = env["QUERY_STRING"]

    @status = 404
    @header = { 'Content-Type' => 'text/plain' }
    @body = ["Resource not found.\n"]

    if method == "GET" && is_time?(path_info)
      handle_query(query_string)
    end

    [@status, @header, @body]
  end

  private

  def is_time?(path_info)
    path_info.sub(TRAILING_SLASHES_PATTERN, "") == "/time"
  end

  def handle_query(query_string)
    if VALID_QUERY_PATTERN.match?(query_string)
      parameters_string = query_string.sub(VALID_QUERY_PATTERN, "")
      handle_parameters(parameters_string)
    else
      @status = 400
      @body = ["Invalid request parameter. Must match pattern '/time?format=... Valid formats are: #{VALID_FORMATS.join(", ")}.\n"]
    end    
  end

  def handle_parameters(parameters_string)    
    formats = parameters_string.split(/\W+/)
    sort_formats(formats)
  end

  def sort_formats(formats)
    valid_formats = []
    invalid_formats = []
    formats.each do |f|
      if VALID_FORMATS.include?(f)
        valid_formats << f
      else
        invalid_formats << f
      end
    end
    handle_formats(valid_formats, invalid_formats)
  end

  def handle_formats(valid_formats, invalid_formats)
    if invalid_formats.any?
      @status = 400
      @body = ["Unknown time formats: #{invalid_formats.join(", ")}.\n"]
    elsif valid_formats.any?
      handle_valid_formats(valid_formats)
    else
      @status = 400
      @body = ["There are no readable formats. Valid ones are: #{VALID_FORMATS.join(", ")}.\n"]
    end 
  end

  def handle_valid_formats(valid_formats)
    time = Time.now
    body_content = []
    valid_formats.map { |vf| vf == "minute" ? "min" : vf }
    valid_formats.map { |vf| vf == "second" ? "sec" : vf }
    valid_formats.each { |vf| body_content << time.instance_eval(vf) }
    body_content = body_content.join("-")
    body_content += "\n"
    @status = 200
    @body = [body_content]
  end
  
end
