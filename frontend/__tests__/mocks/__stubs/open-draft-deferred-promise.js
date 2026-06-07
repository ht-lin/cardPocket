'use strict';
// CJS stub for the ESM-only "@open-draft/deferred-promise" package.
// Implements the minimal DeferredPromise API used by MSW.

class DeferredPromise {
  constructor() {
    this.state = 'pending';
    this._promise = new Promise((res, rej) => {
      this._resolve = res;
      this._reject = rej;
    });
  }
  resolve(value) {
    this.state = 'fulfilled';
    this._resolve(value);
  }
  reject(reason) {
    this.state = 'rejected';
    this._reject(reason);
  }
  then(...args) {
    return this._promise.then(...args);
  }
  catch(...args) {
    return this._promise.catch(...args);
  }
  finally(...args) {
    return this._promise.finally(...args);
  }
}

function createDeferredExecutor() {
  let resolve, reject;
  const executor = (res, rej) => {
    resolve = res;
    reject = rej;
  };
  executor.resolve = (v) => resolve(v);
  executor.reject = (r) => reject(r);
  return executor;
}

module.exports = { DeferredPromise, createDeferredExecutor };
