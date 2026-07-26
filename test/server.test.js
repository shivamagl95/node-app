const test = require('node:test');
const assert = require('node:assert/strict');
const { server, getClientIp } = require('../server');

// Helper to start server on an ephemeral port and return base URL
function startServer() {
  return new Promise((resolve) => {
    server.listen(0, '127.0.0.1', () => {
      const { port } = server.address();
      resolve(`http://127.0.0.1:${port}`);
    });
  });
}

function stopServer() {
  return new Promise((resolve) => server.close(resolve));
}

test('GET / returns 200 with correct content-type', async (t) => {
  const baseUrl = await startServer();
  t.after(async () => stopServer());

  const res = await fetch(`${baseUrl}/`);
  assert.equal(res.status, 200);
  assert.equal(res.headers.get('content-type'), 'application/json');
});

test('GET / response body has timestamp and ip keys', async (t) => {
  const baseUrl = await startServer();
  t.after(async () => stopServer());

  const res = await fetch(`${baseUrl}/`);
  const data = await res.json();

  assert.ok(Object.prototype.hasOwnProperty.call(data, 'timestamp'));
  assert.ok(Object.prototype.hasOwnProperty.call(data, 'ip'));
});

test('timestamp is a valid ISO 8601 date string', async (t) => {
  const baseUrl = await startServer();
  t.after(async () => stopServer());

  const res = await fetch(`${baseUrl}/`);
  const data = await res.json();

  const parsed = new Date(data.timestamp);
  assert.ok(!Number.isNaN(parsed.getTime()), 'timestamp should be a valid date');
  assert.equal(data.timestamp, parsed.toISOString());
});

test('ip field is populated (non-empty string)', async (t) => {
  const baseUrl = await startServer();
  t.after(async () => stopServer());

  const res = await fetch(`${baseUrl}/`);
  const data = await res.json();

  assert.equal(typeof data.ip, 'string');
  assert.ok(data.ip.length > 0);
});

test('unknown route returns 404', async (t) => {
  const baseUrl = await startServer();
  t.after(async () => stopServer());

  const res = await fetch(`${baseUrl}/unknown`);
  assert.equal(res.status, 404);

  const data = await res.json();
  assert.equal(data.error, 'Not Found');
});

test('non-GET method on / is not handled as success (falls through to 404)', async (t) => {
  const baseUrl = await startServer();
  t.after(async () => stopServer());

  const res = await fetch(`${baseUrl}/`, { method: 'POST' });
  assert.equal(res.status, 404);
});

test('getClientIp prefers x-forwarded-for header when present', () => {
  const fakeReq = {
    headers: { 'x-forwarded-for': '203.0.113.5, 70.41.3.18' },
    socket: { remoteAddress: '10.0.0.1' }
  };
  assert.equal(getClientIp(fakeReq), '203.0.113.5');
});

test('getClientIp falls back to socket.remoteAddress when no header', () => {
  const fakeReq = {
    headers: {},
    socket: { remoteAddress: '192.168.1.50' }
  };
  assert.equal(getClientIp(fakeReq), '192.168.1.50');
});