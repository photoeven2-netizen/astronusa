import { createServer as createHttpServer } from 'node:http';
import { resolve } from 'node:path';
import { pathToFileURL } from 'node:url';

import {
  ContractError,
  validateReadingRequest,
  validateReadingResponse,
} from './reading.js';
import { FixedWindowRateLimiter } from './rate-limit.js';

const MAX_BODY_BYTES = 16 * 1024;
const REQUEST_TIMEOUT_MS = 20_000;
const RATE_LIMIT = 5;
const RATE_WINDOW_MS = 10 * 60 * 1000;

function sendJson(response, status, body) {
  response.writeHead(status, {
    'Cache-Control': 'no-store',
    'Content-Type': 'application/json; charset=utf-8',
    'X-Content-Type-Options': 'nosniff',
  });
  response.end(JSON.stringify(body));
}

async function readJsonBody(request) {
  let size = 0;
  let oversized = false;
  const chunks = [];

  for await (const chunk of request) {
    size += chunk.length;
    if (size > MAX_BODY_BYTES) {
      oversized = true;
      chunks.length = 0;
    } else if (!oversized) {
      chunks.push(chunk);
    }
  }

  if (oversized) {
    return { error: 'PAYLOAD_TOO_LARGE' };
  }

  try {
    return { value: JSON.parse(Buffer.concat(chunks).toString('utf8')) };
  } catch (error) {
    if (error instanceof SyntaxError) {
      return { error: 'INVALID_JSON' };
    }
    throw error;
  }
}

function buildPrompt(request) {
  const chart = JSON.stringify(request.chart);
  const numerology = JSON.stringify(request.numerology);
  const question = request.question
    ? `\nPertanyaan lanjutan pengguna: ${JSON.stringify(request.question)}`
    : '';

  return [
    'Kamu adalah AstroGuide, coach astrologi dan numerologi yang hangat, ramah, empatik, dan tidak menakut-nakuti.',
    'Tulis dalam bahasa Indonesia yang ringan dan mudah dipahami. Anggap astrologi dan numerologi sebagai alat refleksi, bukan fakta ilmiah atau kepastian nasib.',
    'Gunakan hanya data ringkasan berikut. Jangan menebak atau menambahkan tanda yang null.',
    'Buat tiap insight ringkas, spesifik, membumi, dan tidak menghakimi. Jangan memberi diagnosis atau nasihat profesional.',
    'Balas dengan satu objek JSON valid saja, tanpa markdown, dengan tepat field: opening, nameInsight, sunInsight, moonInsight, risingInsight, careerLoveInsight, advice, questions.',
    'opening dan nameInsight harus berupa string. sunInsight, moonInsight, risingInsight, atau careerLoveInsight harus null bila data terkait tidak tersedia. advice harus satu kalimat kutipan motivasi, tanpa tanda kutip.',
    'questions harus berisi tepat dua pertanyaan interaktif yang ramah.',
    `Chart sidereal: ${chart}`,
    `Numerologi nama Pythagorean: ${numerology}${question}`,
  ].join('\n');
}

function getGeminiText(payload) {
  const parts = payload?.candidates?.[0]?.content?.parts;
  if (!Array.isArray(parts)) {
    throw new ContractError('INVALID_RESPONSE');
  }
  const text = parts.find((part) => typeof part.text === 'string')?.text;
  if (typeof text !== 'string') {
    throw new ContractError('INVALID_RESPONSE');
  }
  return text;
}

function createGeminiUrl(model, apiKey) {
  const url = new URL(
    `https://generativelanguage.googleapis.com/v1beta/models/${encodeURIComponent(model)}:generateContent`,
  );
  return { url, headers: { 'Content-Type': 'application/json', 'x-goog-api-key': apiKey } };
}

export function createServer({
  apiKey = process.env.GEMINI_API_KEY ?? '',
  model = process.env.GEMINI_MODEL ?? 'gemini-2.5-flash',
  fetchImpl = fetch,
  limiter = new FixedWindowRateLimiter({
    limit: RATE_LIMIT,
    windowMs: RATE_WINDOW_MS,
  }),
} = {}) {
  return createHttpServer(async (request, response) => {
    if (request.method === 'GET' && request.url === '/health') {
      sendJson(response, 200, { status: 'ok' });
      return;
    }
    if (request.url !== '/v1/readings') {
      sendJson(response, 404, { error: { code: 'NOT_FOUND', message: 'Endpoint not found.' } });
      return;
    }
    if (request.method !== 'POST') {
      sendJson(response, 405, { error: { code: 'METHOD_NOT_ALLOWED', message: 'Use POST for this endpoint.' } });
      return;
    }
    if (!limiter.consume(request.socket.remoteAddress ?? 'unknown')) {
      sendJson(response, 429, { error: { code: 'RATE_LIMITED', message: 'Too many readings. Try again later.' } });
      return;
    }
    if (!request.headers['content-type']?.toLowerCase().startsWith('application/json')) {
      sendJson(response, 415, { error: { code: 'UNSUPPORTED_MEDIA_TYPE', message: 'Send a JSON request.' } });
      return;
    }
    if (Number(request.headers['content-length']) > MAX_BODY_BYTES) {
      request.resume();
      sendJson(response, 413, { error: { code: 'PAYLOAD_TOO_LARGE', message: 'Request is too large.' } });
      return;
    }

    let parsedBody;
    try {
      parsedBody = await readJsonBody(request);
    } catch {
      sendJson(response, 400, { error: { code: 'INVALID_REQUEST', message: 'Request could not be read.' } });
      return;
    }
    if (parsedBody.error) {
      const status = parsedBody.error === 'PAYLOAD_TOO_LARGE' ? 413 : 400;
      sendJson(response, status, {
        error: {
          code: parsedBody.error,
          message: status === 413 ? 'Request is too large.' : 'Request must contain valid JSON.',
        },
      });
      return;
    }

    let reading;
    try {
      reading = validateReadingRequest(parsedBody.value);
    } catch (error) {
      if (!(error instanceof ContractError) || error.code !== 'INVALID_REQUEST') {
        sendJson(response, 500, { error: { code: 'INTERNAL_ERROR', message: 'The reading could not be prepared.' } });
        return;
      }
      sendJson(response, 400, { error: { code: 'INVALID_REQUEST', message: 'Request contains unsupported or sensitive fields.' } });
      return;
    }

    if (!apiKey) {
      sendJson(response, 503, { error: { code: 'SERVICE_NOT_CONFIGURED', message: 'AI readings are not configured.' } });
      return;
    }

    let upstream;
    try {
      const geminiRequest = createGeminiUrl(model, apiKey);
      upstream = await fetchImpl(geminiRequest.url, {
        method: 'POST',
        headers: geminiRequest.headers,
        signal: AbortSignal.timeout(REQUEST_TIMEOUT_MS),
        body: JSON.stringify({
          contents: [{ parts: [{ text: buildPrompt(reading) }] }],
          generationConfig: { responseMimeType: 'application/json' },
        }),
      });
    } catch (error) {
      const timedOut = error?.name === 'TimeoutError' || error?.name === 'AbortError';
      sendJson(response, timedOut ? 504 : 502, {
        error: {
          code: timedOut ? 'UPSTREAM_TIMEOUT' : 'UPSTREAM_ERROR',
          message: timedOut
            ? 'The AI provider took too long to respond.'
            : 'The AI provider could not complete this reading.',
        },
      });
      return;
    }

    if (!upstream.ok) {
      sendJson(response, 502, {
        error: { code: 'UPSTREAM_ERROR', message: 'The AI provider could not complete this reading.' },
      });
      return;
    }

    let result;
    try {
      const payload = await upstream.json();
      result = validateReadingResponse(
        JSON.parse(getGeminiText(payload)),
        { availablePositions: reading.chart.positions },
      );
    } catch {
      sendJson(response, 502, {
        error: { code: 'INVALID_AI_RESPONSE', message: 'The AI provider returned an unusable reading.' },
      });
      return;
    }

    sendJson(response, 200, result);
  });
}

const invokedPath = process.argv[1] ? pathToFileURL(resolve(process.argv[1])).href : '';
if (invokedPath === import.meta.url) {
  const port = Number(process.env.PORT ?? 3000);
  const host = process.env.HOST ?? '127.0.0.1';
  const server = createServer();
  server.listen(port, host, () => {
    process.stdout.write(`AstroGuide API listening on http://${host}:${port}\n`);
  });
}
