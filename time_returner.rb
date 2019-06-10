require 'rack'
require 'byebug'
require_relative 'time_formatter'

class TimeReturner

  TRAILING_SLASHES_PATTERN = /\/+$/
  VALID_QUERY_PATTERN = /^(format=)/  

  def call(env)
    @request = Rack::Request.new(env)    

    if time_request?(@request)
      time_response      
    else
      not_time_response      
    end

    [@status, @header, @body]
  end

  private

  def time_request?(request)
    @request.env["REQUEST_METHOD"] == "GET" && request.env["PATH_INFO"].sub(TRAILING_SLASHES_PATTERN, "") == "/time"
  end

  def time_response
    if VALID_QUERY_PATTERN.match?(@request.env["QUERY_STRING"])
      @parameters_string = @request.env["QUERY_STRING"].sub(VALID_QUERY_PATTERN, "")
      valid_parameters_response
    else
      invalid_parameters_response
    end    
  end

  def valid_parameters_response
    @formats = TimeFormatter.new(@parameters_string)
    if !@formats.valid?
      invalid_formats_response
    else
      valid_formats_response
    end
  end

  def valid_formats_response
    body_content = @formats.get_body_content    
    @status = 200
    @header = { 'Content-Type' => 'text/plain' }
    @body = [body_content]
  end

  def not_time_response
    @status = 404
    @header = { 'Content-Type' => 'text/plain' }
    @body = ["Resource not found.\n"]
  end

  def invalid_parameters_response
    @status = 400
    @header = { 'Content-Type' => 'text/plain' }
    @body = ["Invalid request parameter. Must match pattern '/time?format=... Valid formats are: #{VALID_FORMATS.join(", ")}.\n"]
  end

  def invalid_formats_response
    @status = 400
    @header = { 'Content-Type' => 'text/plain' }
    if @formats.invalid.any?
      @body = ["Unknown time formats: #{@formats.invalid.join(", ")}.\n"]
    else
      @body = ["There are no readable formats. Valid ones are: #{VALID_FORMATS.join(", ")}.\n"]
    end
  end

end