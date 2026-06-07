'use strict';
// CJS stub for the ESM-only "rettime" package, which MSW v2 depends on.
// Provides minimal Emitter + TypedEvent for MSW to initialise without errors.

class Emitter {
  constructor() {
    this._listeners = new Map();
  }
  on(event, listener) {
    if (!this._listeners.has(event)) this._listeners.set(event, []);
    this._listeners.get(event).push(listener);
    return this;
  }
  off(event, listener) {
    const ls = this._listeners.get(event);
    if (ls) {
      const i = ls.indexOf(listener);
      if (i !== -1) ls.splice(i, 1);
    }
    return this;
  }
  once(event, listener) {
    const wrapper = (...args) => {
      this.off(event, wrapper);
      return listener(...args);
    };
    return this.on(event, wrapper);
  }
  emit(event, eventObj) {
    const ls = this._listeners.get(event) || [];
    const wildcards = this._listeners.get('*') || [];
    for (const fn of [...ls, ...wildcards]) fn(eventObj);
  }
  removeAllListeners() {
    this._listeners.clear();
    return this;
  }
}

const BaseEvent =
  typeof MessageEvent !== 'undefined'
    ? MessageEvent
    : class MessageEvent {
        constructor(type, init) {
          this.type = type;
          this.data = init && init.data;
        }
      };

class TypedEvent extends BaseEvent {
  constructor(type, init) {
    super(type, init);
  }
  preventDefault() {}
  stopImmediatePropagation() {}
}

module.exports = { Emitter, TypedEvent };
