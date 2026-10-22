import assert from 'node:assert/strict';
import { once } from 'node:events';
import test from 'node:test';

import { createServer } from '../src/server.js';

const requestBody = {
  chart: {
    ayanamsha: 'lahiri',
    birthTimeKnown: true,
    positions: {
      sun: 'Leo',
      moon: 'Virgo',
      rising: 'Taurus',
      mars: 'Gemini',
      venus: 'Cancer',
    },
  },
  numerology: {
    expression: 7,
    soulUrge: 11,
    personality: 5,
  },
};

async function startServer(options) {
  const server = createServer(options);
  server.listen(0, '127.0.0.1');
  await once(server, 'listening');
  const address = server.address();
  return {
    server,
    baseUrl: `http://127.0.0.1:${address.port}`,
  };
}

test('reports health without exposing whether a Gemini key is configured', async (t) => {
  const { server, baseUrl } = await startServer({ apiKey: '' });
  t.after(() => server.close());

  const response = await fetch(`${baseUrl}/health`);
  assert.equal(response.status, 200);
  assert.deepEqual(await response.json(), { status: 'ok' });
});

test('returns an explicit configuration error when the Gemini key is missing', async (t) => {
  const { server, baseUrl } = await startServer({ apiKey: '' });
  t.after(() => server.close());

  const response = await fetch(`${baseUrl}/v1/readings`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify(requestBody),
  });

  assert.equal(response.status, 503);
  assert.deepEqual(await response.json(), {
    error: { code: 'SERVICE_NOT_CONFIGURED', message: 'AI readings are not configured.' },
  });
});

test('sends only the validated chart, numerology, and question to Gemini', async (t) => {
  let upstreamRequest;
  const { server, baseUrl } = await startServer({
    apiKey: 'server-only-secret',
    fetchImpl: async (url, options) => {
      upstreamRequest = { url, options, body: JSON.parse(options.body) };
      return Response.json({
        candidates: [{
          content: {
            parts: [{
              text: JSON.stringify({
                opening: 'Perpaduan energimu terasa penuh rasa ingin tahu.',
                nameInsight: 'Angka ekspresi 7 menggambarkan kedalaman berpikir.',
                sunInsight: 'Leo membawa kehangatan dan keberanian.',
                moonInsight: 'Virgo merasa aman dalam ritme yang teratur.',
                risingInsight: 'Taurus memberi kesan yang tenang.',
                careerLoveInsight: 'Mars di Gemini mencari ide segar; Venus di Cancer mendambakan kedekatan.',
                advice: 'Berikan ruang bagi prosesmu hari ini.',
                questions: ['Bagian mana yang paling terasa dekat?', 'Mau lanjut soal apa?'],
              }),
            }],
          },
        }],
      });
    },
  });
  t.after(() => server.close());

  const response = await fetch(`${baseUrl}/v1/readings`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ ...requestBody, question: 'Bagaimana dengan pekerjaanku?' }),
  });

  assert.equal(response.status, 200);
  assert.equal(typeof (await response.json()).opening, 'string');
  assert.match(upstreamRequest.url.toString(), /gemini-2\.5-flash:generateContent/);
  assert.equal(upstreamRequest.options.headers['x-goog-api-key'], 'server-only-secret');
  assert.doesNotMatch(upstreamRequest.url.toString(), /server-only-secret/);
  const prompt = JSON.stringify(upstreamRequest.body);
  assert.match(prompt, /Leo/);
  assert.match(prompt, /Bagaimana dengan pekerjaanku/);
  assert.doesNotMatch(prompt, /"(fullName|birthDate|birthTime|latitude|longitude)"/);
});

test('rejects raw birth details before calling Gemini', async (t) => {
  let upstreamCalls = 0;
  const { server, baseUrl } = await startServer({
    apiKey: 'server-only-secret',
    fetchImpl: async () => {
      upstreamCalls += 1;
      return Response.json({});
    },
  });
  t.after(() => server.close());

  const response = await fetch(`${baseUrl}/v1/readings`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ ...requestBody, fullName: 'Nama Rahasia' }),
  });

  assert.equal(response.status, 400);
  assert.equal(upstreamCalls, 0);
});

test('returns a clear error instead of a success-shaped result on upstream failure', async (t) => {
  const { server, baseUrl } = await startServer({
    apiKey: 'server-only-secret',
    fetchImpl: async () => new Response('upstream details', { status: 429 }),
  });
  t.after(() => server.close());

  const response = await fetch(`${baseUrl}/v1/readings`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify(requestBody),
  });

  assert.equal(response.status, 502);
  assert.deepEqual(await response.json(), {
    error: { code: 'UPSTREAM_ERROR', message: 'The AI provider could not complete this reading.' },
  });
});
