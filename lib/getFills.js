/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
require("dotenv").config({ silent: true });

// mongo = require('mongodb').MongoClient
const RSVP = require("rsvp");

const moment = require("moment");

const mongoConnection = require("../lib/mongoConnection");

const RESET_DATE = "2018-01-01T00:00:00.000Z";

const defaultOptions = {
  sort_trade_id: -1,
  limit: 10
};

const getFills = (product, side, opts = defaultOptions) => {
  return new RSVP.Promise((resolve, reject) =>
    mongoConnection().then(db => {
      const collection = db.collection("fills");

      const onError = err => {
        console.log("getFills.err", err);
        return reject(err);
      };

      const search = {
        product_id: product,
        side,
        created_at: {
          $gte: RESET_DATE
        }
      };

      console.log(search);

      collection
        .find(search)
        .sort(opts.sort)
        // .sort({ created_at: -1 })
        .limit(opts.limit)
        .toArray()
        .then(resolve)
        .catch(onError);
    })
  );
};

module.exports = getFills;
