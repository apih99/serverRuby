# Test script for web server
Write-Host "Starting Web Server Tests`n" -ForegroundColor Cyan

function Test-WebServer {
    param (
        [string]$Uri,
        [string]$TestName,
        [string]$Method = "GET"
    )
    
    Write-Host "`nRunning Test: $TestName" -ForegroundColor Green
    try {
        $response = Invoke-WebRequest -Uri $Uri -Method $Method -UseBasicParsing -TimeoutSec 5
        Write-Host "Status: $($response.StatusCode) $($response.StatusDescription)"
        Write-Host "Content Type: $($response.Headers['Content-Type'])"
        Write-Host "Content Length: $($response.Headers['Content-Length'])"
        Write-Host "Content: $($response.Content.Substring(0, [Math]::Min(100, $response.Content.Length)))..."
    }
    catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    Write-Host "-----------------"
}

# Test 1: Basic HTML access
Test-WebServer -Uri "http://localhost:4221/" -TestName "Basic HTML Access"

# Test 2: Access text file
Test-WebServer -Uri "http://localhost:4221/test.txt" -TestName "Text File Access"

# Test 3: Non-existent file
Test-WebServer -Uri "http://localhost:4221/notfound.html" -TestName "404 Not Found Test"

# Test 4: Directory traversal attempt
Test-WebServer -Uri "http://localhost:4221/../server.rb" -TestName "Directory Traversal Test"

# Test 5: Invalid method
Test-WebServer -Uri "http://localhost:4221/" -Method "POST" -TestName "Invalid Method Test"

# Test 6: Special characters in URL
Test-WebServer -Uri "http://localhost:4221/test%20file.html" -TestName "URL Encoding Test"

Write-Host "`nTests Complete!" -ForegroundColor Cyan 