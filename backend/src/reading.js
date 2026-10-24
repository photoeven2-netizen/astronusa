const SIGNS = new Set([
  'Aries',
  'Taurus',
  'Gemini',
  'Cancer',
  'Leo',
  'Virgo',
  'Libra',
  'Scorpio',
  'Sagittarius',
  'Capricorn',
  'Aquarius',
  'Pisces',
]);

const AYANAMSHAS = new Set(['tropical', 'lahiri', 'raman', 'kp']);
const POSITION_NAMES = ['sun', 'moon', 'rising', 'mars', 'venus'];
const NUMEROLOGY_NAMES = ['expression', 'soulUrge', 'personality'];
const NUMEROLOGY_VALUES = new Set([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 22, 33]);

export class ContractError extends Error {
  constructor(code) {
    super(code);
    this.code = code;
  }
}

function isPlainObject(value) {
  return value !== null && typeof value === 'object' && !Array.isArray(value);
}

function hasExactKeys(value, keys) {
  return isPlainObject(value)
    && Object.keys(value).length === keys.length
    && keys.every((key) => Object.hasOwn(value, key));
}

function requireKeys(value, keys, code) {
  if (!hasExactKeys(value, keys)) {
    throw new ContractError(code);
  }
}

export function validateReadingRequest(value) {
  const requestKeys = value?.question === undefined
    ? ['chart', 'numerology']
    : ['chart', 'numerology', 'question'];
  requireKeys(value, requestKeys, 'INVALID_REQUEST');
  requireKeys(value.chart, ['ayanamsha', 'birthTimeKnown', 'positions'], 'INVALID_REQUEST');
  requireKeys(value.chart.positions, POSITION_NAMES, 'INVALID_REQUEST');
  requireKeys(value.numerology, NUMEROLOGY_NAMES, 'INVALID_REQUEST');

  if (!AYANAMSHAS.has(value.chart.ayanamsha) || typeof value.chart.birthTimeKnown !== 'boolean') {
    throw new ContractError('INVALID_REQUEST');
  }

  for (const name of POSITION_NAMES) {
    const sign = value.chart.positions[name];
    if (sign !== null && (typeof sign !== 'string' || !SIGNS.has(sign))) {
      throw new ContractError('INVALID_REQUEST');
    }
  }
  if (!value.chart.birthTimeKnown && value.chart.positions.rising !== null) {
    throw new ContractError('INVALID_REQUEST');
  }

  for (const name of NUMEROLOGY_NAMES) {
    if (!NUMEROLOGY_VALUES.has(value.numerology[name])) {
      throw new ContractError('INVALID_REQUEST');
    }
  }

  if (value.question !== undefined
    && (typeof value.question !== 'string' || value.question.length > 1000)) {
    throw new ContractError('INVALID_REQUEST');
  }

  return value;
}

const RESPONSE_FIELDS = [
  'opening',
  'nameInsight',
  'sunInsight',
  'moonInsight',
  'risingInsight',
  'careerLoveInsight',
  'advice',
  'questions',
];

export function validateReadingResponse(value, { availablePositions } = {}) {
  if (!hasExactKeys(value, RESPONSE_FIELDS)) {
    throw new ContractError('INVALID_RESPONSE');
  }

  const maxLengths = {
    opening: 400,
    nameInsight: 800,
    sunInsight: 800,
    moonInsight: 800,
    risingInsight: 800,
    careerLoveInsight: 800,
    advice: 800,
  };

  for (const [field, maxLength] of Object.entries(maxLengths)) {
    const mayBeUnavailable = [
      'sunInsight',
      'moonInsight',
      'risingInsight',
      'careerLoveInsight',
    ].includes(field);
    if (value[field] === null && mayBeUnavailable) {
      continue;
    }
    if (typeof value[field] !== 'string'
      || value[field].trim().length === 0
      || value[field].length > maxLength) {
      throw new ContractError('INVALID_RESPONSE');
    }
  }

  if (!Array.isArray(value.questions)
    || value.questions.length !== 2
    || value.questions.some((question) => (
      typeof question !== 'string'
      || question.trim().length === 0
      || question.length > 240
    ))) {
    throw new ContractError('INVALID_RESPONSE');
  }

  if (availablePositions) {
    for (const [field, position] of Object.entries({
      sunInsight: 'sun',
      moonInsight: 'moon',
    })) {
      if ((availablePositions[position] === null) !== (value[field] === null)) {
        throw new ContractError('INVALID_RESPONSE');
      }
    }

    const marsAvailable = availablePositions.mars !== null;
    const venusAvailable = availablePositions.venus !== null;
    if ((marsAvailable || venusAvailable) !== (value.careerLoveInsight !== null)) {
      throw new ContractError('INVALID_RESPONSE');
    }

    if ((availablePositions.rising === null) !== (value.risingInsight === null)) {
      throw new ContractError('INVALID_RESPONSE');
    }
  }

  return value;
}
