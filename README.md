# Ruby Simple Web Server

A lightweight, secure, and multi-threaded web server implemented in Ruby. This project was built following the [Coding Challenges - Web Server](https://codingchallenges.fyi/challenges/challenge-webserver) specification.

## Features

- **Basic HTTP Server**
  - HTTP/1.1 protocol support
  - GET method support
  - Proper HTTP status codes and headers
  - Content-Type detection

- **Security**
  - Directory traversal prevention
  - Restricted file access to `www` directory
  - File extension whitelist
  - Request size limits
  - URL encoding/decoding support

- **Performance**
  - Multi-threaded request handling
  - Thread pooling and cleanup
  - Request timeout handling
  - Concurrent client support

- **Logging**
  - Detailed request logging
  - Error tracking
  - Thread identification

## Requirements

- Ruby (recommended version 3.0 or higher)
- Windows, Linux, or macOS

## Installation

1. Clone the repository:
   ```bash
   git clone [repository-url]
   cd ruby-web-server
   ```

2. No additional gems are required as the server uses only Ruby standard libraries:
   - socket
   - pathname
   - uri
   - timeout

## Usage

1. Start the server:
   ```bash
   ruby server.rb
   ```
   The server will start on port 4221 by default.

2. Place your web files in the `www` directory. The server comes with:
   - `index.html`: Default landing page
   - `test.txt`: Sample text file
   - Other test files

3. Access your files through a web browser or curl:
   ```bash
   curl http://localhost:4221/
   curl http://localhost:4221/index.html
   curl http://localhost:4221/test.txt
   ```

## Configuration

The server can be configured through the following constants in `server.rb`:

```ruby
ALLOWED_EXTENSIONS = %w[.html .htm .txt .css .js].freeze
REQUEST_TIMEOUT = 5  # seconds
MAX_REQUEST_SIZE = 1024 * 1024  # 1MB
```

## Directory Structure

```
.
├── README.md
├── server.rb              # Main server implementation
├── test_server.ps1        # PowerShell test script
└── www/                   # Web root directory
    ├── index.html        # Default page
    ├── test.txt         # Test text file
    └── test file.html   # Test file with spaces
```

## Testing

The project includes a PowerShell test script that verifies:
- Basic HTML serving
- Text file serving
- 404 handling
- Directory traversal prevention
- Invalid method handling
- URL encoding support

Run the tests:
```powershell
.\test_server.ps1
```

## Security Features

1. **Path Sanitization**
   - All paths are sanitized using `Pathname`
   - Prevents directory traversal attacks
   - Blocks access to files outside `www` directory

2. **File Access Control**
   - Whitelist of allowed file extensions
   - No directory listing
   - No symlink following

3. **Request Limits**
   - Maximum request size enforcement
   - Request timeout handling
   - Limited HTTP methods (GET only)

## Logging

The server provides detailed logging:
```
[2025-01-10 23:02:37 +0800] INFO: New connection accepted (Thread: 60)
[2025-01-10 23:02:37 +0800] INFO: GET / HTTP/1.1
[2025-01-10 23:02:37 +0800] INFO: 200 OK - /
```

## Error Handling

- 404 Not Found: Invalid paths
- 405 Method Not Allowed: Non-GET requests
- 408 Request Timeout: Slow clients
- 500 Internal Server Error: Server issues

## Performance

- Multi-threaded design handles concurrent connections
- Thread cleanup prevents memory leaks
- Request timeouts prevent hanging connections
- Efficient file serving with proper content types

## Contributing

Feel free to submit issues, fork the repository, and create pull requests for any improvements.

## License

This project is open source and available under the MIT License.

## Acknowledgments

- Built following the [Coding Challenges](https://codingchallenges.fyi/) specification
- Uses Ruby standard libraries for core functionality 