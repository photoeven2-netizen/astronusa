export class FixedWindowRateLimiter {
  #entries = new Map();
  #requests = 0;

  constructor({ limit, windowMs, maxKeys = 10_000 }) {
    this.limit = limit;
    this.windowMs = windowMs;
    this.maxKeys = maxKeys;
  }

  consume(key, now = Date.now()) {
    this.#requests += 1;
    if (this.#requests % 256 === 0) {
      for (const [entryKey, entry] of this.#entries) {
        if (entry.expiresAt <= now) {
          this.#entries.delete(entryKey);
        }
      }
    }

    let entry = this.#entries.get(key);
    if (entry && entry.expiresAt <= now) {
      this.#entries.delete(key);
      entry = undefined;
    }
    if (!entry) {
      if (this.#entries.size >= this.maxKeys) {
        return false;
      }
      entry = { count: 0, expiresAt: now + this.windowMs };
      this.#entries.set(key, entry);
    }
    if (entry.count >= this.limit) {
      return false;
    }

    entry.count += 1;
    return true;
  }
}
