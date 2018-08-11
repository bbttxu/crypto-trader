/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
require('dotenv').config({ silent: true });
const Gdax = require('gdax');
const RSVP = require('rsvp');

// Func program lib
const { map, keys, isNil, merge } = require('ramda');

const moment = require('moment');

// Some
const { get } = require('axios');

const exit = require('./exit');

/*
               __  .__               .____________ .__  .__               __
_____   __ ___/  |_|  |__   ____   __| _/\_   ___ \|  | |__| ____   _____/  |_
\__  \ |  |  \   __\  |  \_/ __ \ / __ | /    \  \/|  | |  |/ __ \ /    \   __\
 / __ \|  |  /|  | |   Y  \  ___// /_/ | \     \___|  |_|  \  ___/|   |  \  |
(____  /____/ |__| |___|  /\___  >____ |  \______  /____/__|\___  >___|  /__|
     \/                 \/     \/     \/         \/             \/     \/

local scoped client
if we need to restart, we have a local scoped variable onto which we can re-attach a new instance
*/

// 0 auth mechanism
const authedClient = () => {
  const client = new Gdax.AuthenticatedClient(process.env.API_KEY, process.env.API_SECRET, process.env.API_PASSPHRASE);
  // console.log moment().format(), 'gdax authedClient', client
  return client;
};

// 1 mechanism to create auth mechanism to gdax
// reinitAuthedClient = ->
//   authedClient = new Gdax.AuthenticatedClient(process.env.API_KEY, process.env.API_SECRET, process.env.API_PASSPHRASE)
//   console.log moment().format(), 'gdax authedClient', authedClient

// reinitAuthedClient() # 2 get things started

const clientReject = err => {
  console.log('gdax client by error clientReject', err);

  return exit();
};

/*
                __  .__               .___
  _____   _____/  |_|  |__   ____   __| _/______
 /     \_/ __ \   __\  |  \ /  _ \ / __ |/  ___/
|  Y Y  \  ___/|  | |   Y  (  <_> ) /_/ |\___ \
|__|_|  /\___  >__| |___|  /\____/\____ /____  >
      \/     \/          \/            \/    \/
*/

const cancelAllOrders = (currencies = []) =>
  new RSVP.Promise((resolve1, rejectPromise1) => {
    const promiseCancelCurrencyOrder = currency =>
      new RSVP.Promise((resolve2, reject2) =>
        authedClient().cancelAllOrders({ product_id: currency }, (err, results) => {
          if (err || undefined === results) {
            console.log('cancelAllOrders.err', err);
            return reject2(err);
          } else {
            return resolve2(results.body);
          }
        })
      );

    const cancelAllCurrencyOrders = map(promiseCancelCurrencyOrder, currencies);

    const rejectPromise = promise => rejectPromise1(promise);

    const resolveIssues = issues => resolve1(issues);

    return RSVP.allSettled(cancelAllCurrencyOrders).then(resolveIssues).catch(rejectPromise);
  });

const getProduct24HrStats = product =>
  new RSVP.Promise((resolve, rejectPromise) => {
    const publicClient = new Gdax.PublicClient(product);

    const callback = (err, json) => {
      if (err) {
        rejectPromise(err);
      }

      if (!json) {
        rejectPromise({
          func: 'getProduct24HrStats',
          message: 'no JSON response',
          json
        });
      }

      if (!json.body) {
        rejectPromise({
          func: 'getProduct24HrStats',
          message: 'no JSON response body',
          json
        });
      }

      const body = JSON.parse(json.body);

      if (isNil(body.message)) {
        const obj = {};
        obj[product] = body;

        resolve(obj);
      }

      return rejectPromise(body);
    };

    return publicClient.getProduct24HrStats(callback);
  });

const stats = (currencies = []) =>
  new RSVP.Promise((resolve, reject) => {
    const allCurrencyStats = map(getProduct24HrStats, currencies);

    const rejectPromise = promise => reject(promise);

    const resolveIssues = issues => resolve(issues);

    return RSVP.all(allCurrencyStats).then(resolveIssues).catch(rejectPromise);
  });

//
// single stat for single product_id
const stat = (product_id, params = { granularity: 60 }) => get(`https://api.gdax.com/products/${product_id}/candles`, { params });

const getAccounts = currency =>
  // console.log currency
  new RSVP.Promise((resolve, rejectPromise) => {
    const callback = (err, json) => {
      if (err) {
        rejectPromise(err);
      }
      if (json) {
        resolve(JSON.parse(json.toJSON().body));
      }

      return resolve([]);
    };

    return authedClient().getAccounts(callback);
  });

const cancelOrder = order =>
  new RSVP.Promise((resolve, rejectPromise) => {
    const callback = (err, data) => {
      if (err) {
        console.log('err cancelOrder', err, order);
        rejectPromise(false);
      }

      if (!data) {
        rejectPromise(false);
      }

      const payload = JSON.parse(data.body);

      // we ensure the trade was deleted by checking that it was already removed from the orderbook
      if ('NotFound' === payload.message) {
        return resolve(true);
      } else {
        return rejectPromise(payload.message);
      }
    };

    return authedClient().cancelOrder(order, callback);
  });

const buy = order =>
  new RSVP.Promise((resolve, reject) => {
    const callback = (err, result) => {
      if (err) {
        clientReject(err);
        reject(err);
      }

      return resolve(result);
    };

    return authedClient().buy(order, callback);
  });

const sell = order =>
  new RSVP.Promise((resolve, reject) => {
    const callback = (err, result) => {
      if (err) {
        reject(err);
      }
      return resolve(result);
    };

    return authedClient().sell(order, callback);
  });

const getFills = (product, args = {}) => {
  const payload = merge(args, { product_id: product });

  return new RSVP.Promise((resolve, reject) =>
    authedClient().getFills(payload, (err, data) => {
      if (err) {
        data = JSON.parse(err.body);
        console.log('err getFills', data, order);
        reject(err.body);
      }

      return resolve(JSON.parse(data.body));
    })
  );
};

const getOrders = product_id =>
  new RSVP.Promise((resolve, reject) => {
    const callback = result => {
      console.log('result', result);
      return resolve(result);
    };

    return authedClient().getOrders(product_id, callback);
  });

/*                                  __
  ____ ___  _________   ____________/  |_  ______
_/ __ \\  \/  /\____ \ /  _ \_  __ \   __\/  ___/
\  ___/ >    < |  |_> >  <_> )  | \/|  |  \___ \
 \___  >__/\_ \|   __/ \____/|__|   |__| /____  >
     \/      \/|__|                           \/*/

module.exports = {
  cancelAllOrders,
  getProduct24HrStats,

  // multiple or single
  stats,
  stat,

  getAccounts,

  cancelOrder,
  buy,
  sell,

  getFills,
  getOrders
};
