/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const { Promise } = require('rsvp');

const mongoConnection = require('./mongoConnection');

const memoize = require('lodash.memoize');

const mongoDb = database =>
  //
  //
  new Promise((
    resolve,
    reject //
  ) =>
    //
    mongoConnection().then(db => resolve(db.collection(database)))
  );

module.exports = memoize(mongoDb);
