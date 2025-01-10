require 'socket'
require 'pathname'
require 'uri'
require 'timeout'

class WebServer
  ALLOWED_EXTENSIONS = %w[.html .htm .txt .css .js].freeze
  REQUEST_TIMEOUT = 5  # seconds
  MAX_REQUEST_SIZE = 1024 * 1024  # 1MB
  
  def initialize(port = 4221, www_root = 'www')
    @port = port
    @www_root = File.expand_path(www_root)
    @threads = []
    
    # Ensure www directory exists
    Dir.mkdir(@www_root) unless Dir.exist?(@www_root)
  end

  def start
    server = TCPServer.new(@port)
    puts "Server listening on port #{@port}"
    puts "Serving files from: #{@www_root}"

    loop do
      client = server.accept
      thread = Thread.new(client) do |client_connection|
        begin
          Timeout.timeout(REQUEST_TIMEOUT) do
            handle_connection(client_connection)
          end
        rescue Timeout::Error
          log_error("Request timed out")
          send_response(client_connection, 408, 'Request Timeout')
        rescue StandardError => e
          log_error("Error handling connection: #{e.message}")
          send_response(client_connection, 500, 'Internal Server Error')
        ensure
          client_connection.close
        end
      end

      @threads << thread
      cleanup_threads
    end
  rescue StandardError => e
    log_error("Server error: #{e.message}")
  ensure
    cleanup_threads(true)
  end

  private

  def cleanup_threads(wait = false)
    @threads.delete_if do |thread|
      if wait
        thread.join
        true
      else
        !thread.alive?
      end
    end
  end

  def handle_connection(client)
    log_info("New connection accepted (Thread: #{Thread.current.object_id})")
    
    request_size = 0
    request_line = client.gets
    request_size += request_line.length if request_line
    
    if request_line
      method, raw_path, version = request_line.split(' ')
      path = URI.decode_www_form_component(raw_path)
      
      log_info("#{method} #{path} #{version}")
      
      # Read headers with size limit
      headers = {}
      while line = client.gets
        request_size += line.length
        break if line.strip.empty?
        break if request_size > MAX_REQUEST_SIZE
        
        if line =~ /^([^:]+):\s*(.+)$/
          headers[$1] = $2.strip
        end
      end
      
      sleep(1) if ENV['DEMO_DELAY']
      
      case method
      when 'GET'
        serve_file(client, path)
      else
        send_response(client, 405, 'Method Not Allowed')
      end
    end
  end

  def serve_file(client, path)
    file_path = get_file_path(path)
    
    if file_path && File.file?(file_path) && allowed_file?(file_path)
      begin
        content = File.read(file_path)
        log_info("200 OK - #{path}")
        send_response(client, 200, 'OK', content, content_type(file_path))
      rescue StandardError => e
        log_error("Error reading file: #{e.message}")
        send_response(client, 500, 'Internal Server Error')
      end
    else
      log_info("404 Not Found - #{path}")
      send_response(client, 404, 'Not Found')
    end
  end

  def get_file_path(path)
    # Handle root path
    path = '/index.html' if path == '/'
    
    begin
      # Remove leading slash and clean path
      clean_path = Pathname.new(path).cleanpath.to_s.gsub(/^\//, '')
      
      # Join with www root
      file_path = File.join(@www_root, clean_path)
      
      # Convert to absolute path
      absolute_path = File.expand_path(file_path)
      
      # Security checks
      if absolute_path.start_with?(@www_root) && 
         !File.directory?(absolute_path) &&
         !File.symlink?(absolute_path)
        absolute_path
      end
    rescue ArgumentError => e
      log_error("Invalid path: #{e.message}")
      nil
    end
  end

  def allowed_file?(file_path)
    ALLOWED_EXTENSIONS.include?(File.extname(file_path).downcase)
  end

  def content_type(file_path)
    case File.extname(file_path).downcase
    when '.html', '.htm'
      'text/html'
    when '.txt'
      'text/plain'
    when '.css'
      'text/css'
    when '.js'
      'application/javascript'
    else
      'application/octet-stream'
    end
  end

  def send_response(client, status_code, status_text, content = nil, content_type = 'text/plain')
    response = "HTTP/1.1 #{status_code} #{status_text}\r\n"
    response += "Server: Ruby Web Server\r\n"
    response += "Content-Type: #{content_type}\r\n"
    
    if content
      response += "Content-Length: #{content.bytesize}\r\n"
      response += "\r\n"
      response += content
    else
      response += "Content-Length: 0\r\n"
      response += "\r\n"
    end
    
    client.write(response)
  end

  def log_info(message)
    puts "[#{Time.now}] INFO: #{message}"
  end

  def log_error(message)
    puts "[#{Time.now}] ERROR: #{message}"
  end
end

# Start the server if this file is run directly
if __FILE__ == $PROGRAM_NAME
  server = WebServer.new
  server.start
end 