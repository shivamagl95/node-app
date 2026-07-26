const http = require('http');

const PORT = process.env.PORT || 3000;

function getClientIp(req) {
  const forwarded = req.headers['x-forwarded-for'];
  if (forwarded) {
    return forwarded.split(',')[0].trim();
  }
  return req.socket.remoteAddress;
}

function requestHandler(req, res) {
  if (req.method === 'GET' && req.url === '/') {
    const body = JSON.stringify({
      timestamp: new Date().toISOString(),
      ip: getClientIp(req)
    });

    res.writeHead(200, {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(body)
    });
    res.end(body);
    return;
  }

  res.writeHead(404, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({ error: 'Not Found' }));
}

const server = http.createServer(requestHandler);

// Only start listening when run directly (not when imported in tests)
if (require.main === module) {
  server.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });

  process.on('SIGTERM', () => {
    server.close(() => process.exit(0));
  });
}

module.exports = { server, requestHandler, getClientIp };