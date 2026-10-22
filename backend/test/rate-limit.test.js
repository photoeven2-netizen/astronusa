import assert from 'node:assert/strict';
import test from 'node:test';

import { FixedWindowRateLimiter } from '../src/rate-limit.js';

test('limits each key independently and reopens it after the fixed window', () => {
  const limiter = new FixedWindowRateLimiter({ limit: 2, windowMs: 1000 });

  assert.equal(limiter.consume('device-a', 100), true);
  assert.equal(limiter.consume('device-a', 200), true);
  assert.equal(limiter.consume('device-a', 300), false);
  assert.equal(limiter.consume('device-b', 300), true);
  assert.equal(limiter.consume('device-a', 1100), true);
});

test('fails closed when the bounded key table is full', () => {
  const limiter = new FixedWindowRateLimiter({
    limit: 10,
    windowMs: 1000,
    maxKeys: 1,
  });

  assert.equal(limiter.consume('device-a', 100), true);
  assert.equal(limiter.consume('device-b', 100), false);
});
