import assert from 'node:assert/strict';
import test from 'node:test';

import {
  validateReadingRequest,
  validateReadingResponse,
} from '../src/reading.js';

const validRequest = {
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

const validResponse = {
  opening: 'Perpaduan energimu mengajakmu mengenali arahmu dengan lembut.',
  nameInsight: 'Angka ekspresi 7 menggambarkan rasa ingin tahu dan kedalaman berpikir.',
  sunInsight: 'Leo menambah keberanian untuk tampil tulus dan hangat.',
  moonInsight: 'Virgo menemukan rasa aman lewat rutinitas yang terasa menenangkan.',
  risingInsight: 'Taurus memberi kesan pertama yang tenang dan bersahaja.',
  careerLoveInsight: 'Mars di Gemini senang bertukar ide, sementara Venus di Cancer menghargai kedekatan.',
  advice: 'Langkah kecil yang konsisten tetap layak dirayakan.',
  questions: [
    'Bagian mana dari bacaan ini yang terasa paling dekat?',
    'Mau membahas relasi atau pekerjaan lebih dulu?',
  ],
};

test('accepts the minimized chart and numerology summary', () => {
  assert.deepEqual(validateReadingRequest(validRequest), validRequest);
});

test('accepts zero for an empty vowel or consonant subtotal', () => {
  const request = {
    ...validRequest,
    numerology: { ...validRequest.numerology, personality: 0 },
  };

  assert.deepEqual(validateReadingRequest(request), request);
});

test('rejects full names and raw birth details at the API boundary', () => {
  const unsafeRequest = {
    ...validRequest,
    fullName: 'Nama Rahasia',
    birthDate: '2001-02-03',
    birthTime: '04:05',
    city: 'Jakarta',
    latitude: -6.2,
    longitude: 106.8,
  };

  assert.throws(() => validateReadingRequest(unsafeRequest), {
    code: 'INVALID_REQUEST',
  });
});

test('rejects raw locations nested in chart data', () => {
  const unsafeRequest = {
    ...validRequest,
    chart: { ...validRequest.chart, city: 'Jakarta' },
  };

  assert.throws(() => validateReadingRequest(unsafeRequest), {
    code: 'INVALID_REQUEST',
  });
});

test('requires the Rising position to be absent when birth time is unknown', () => {
  const unknownTimeRequest = {
    ...validRequest,
    chart: {
      ...validRequest.chart,
      birthTimeKnown: false,
    },
  };

  assert.throws(() => validateReadingRequest(unknownTimeRequest), {
    code: 'INVALID_REQUEST',
  });

  const safeRequest = {
    ...unknownTimeRequest,
    chart: {
      ...unknownTimeRequest.chart,
      positions: { ...validRequest.chart.positions, rising: null },
    },
  };

  assert.deepEqual(validateReadingRequest(safeRequest), safeRequest);
});

test('rejects unsupported ayanamshas, signs, and out-of-range degrees', () => {
  for (const change of [
    (request) => { request.chart.ayanamsha = 'tropical'; },
    (request) => { request.chart.positions.sun = 'Ophiuchus'; },
    (request) => { request.chart.positions.moon = 360; },
  ]) {
    const request = structuredClone(validRequest);
    change(request);
    assert.throws(() => validateReadingRequest(request), {
      code: 'INVALID_REQUEST',
    });
  }
});

test('accepts only an optional, bounded follow-up question', () => {
  assert.equal(
    validateReadingRequest({ ...validRequest, question: 'Bagaimana dengan gaya kerjaku?' }).question,
    'Bagaimana dengan gaya kerjaku?',
  );

  assert.throws(
    () => validateReadingRequest({ ...validRequest, question: 'x'.repeat(1001) }),
    { code: 'INVALID_REQUEST' },
  );
});

test('accepts a complete AstroGuide response with two conversation prompts', () => {
  assert.deepEqual(validateReadingResponse(validResponse), validResponse);
});

test('never allows a response to invent a Rising reading when birth time is unknown', () => {
  const response = { ...validResponse, risingInsight: 'Taurus memberi kesan yang tenang.' };

  assert.throws(
    () => validateReadingResponse(response, {
      availablePositions: { sun: 'Leo', moon: 'Virgo', rising: null, mars: 'Gemini', venus: 'Cancer' },
    }),
    { code: 'INVALID_RESPONSE' },
  );
});

test('rejects malformed, oversized, or success-shaped fallback responses', () => {
  for (const response of [
    { ...validResponse, questions: ['Satu pertanyaan saja'] },
    { ...validResponse, extra: 'unexpected' },
    { ...validResponse, advice: '' },
    { ...validResponse, advice: 'a'.repeat(801) },
  ]) {
    assert.throws(() => validateReadingResponse(response), {
      code: 'INVALID_RESPONSE',
    });
  }
});

test('requires unknown Rising data and insight to remain explicitly absent', () => {
  const response = { ...validResponse, risingInsight: null };

  assert.deepEqual(
    validateReadingResponse(response, {
      availablePositions: { sun: 'Leo', moon: 'Virgo', rising: null, mars: 'Gemini', venus: 'Cancer' },
    }),
    response,
  );

  assert.throws(
    () => validateReadingResponse(validResponse, {
      availablePositions: { sun: 'Leo', moon: 'Virgo', rising: null, mars: 'Gemini', venus: 'Cancer' },
    }),
    { code: 'INVALID_RESPONSE' },
  );
});
