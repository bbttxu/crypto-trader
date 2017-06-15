module.exports =
/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId]) {
/******/ 			return installedModules[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// identity function for calling harmony imports with the correct context
/******/ 	__webpack_require__.i = function(value) { return value; };
/******/
/******/ 	// define getter function for harmony exports
/******/ 	__webpack_require__.d = function(exports, name, getter) {
/******/ 		if(!__webpack_require__.o(exports, name)) {
/******/ 			Object.defineProperty(exports, name, {
/******/ 				configurable: false,
/******/ 				enumerable: true,
/******/ 				get: getter
/******/ 			});
/******/ 		}
/******/ 	};
/******/
/******/ 	// getDefaultExport function for compatibility with non-harmony modules
/******/ 	__webpack_require__.n = function(module) {
/******/ 		var getter = module && module.__esModule ?
/******/ 			function getDefault() { return module['default']; } :
/******/ 			function getModuleExports() { return module; };
/******/ 		__webpack_require__.d(getter, 'a', getter);
/******/ 		return getter;
/******/ 	};
/******/
/******/ 	// Object.prototype.hasOwnProperty.call
/******/ 	__webpack_require__.o = function(object, property) { return Object.prototype.hasOwnProperty.call(object, property); };
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(__webpack_require__.s = 24);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ (function(module, exports) {

module.exports = require("ramda");

/***/ }),
/* 1 */
/***/ (function(module, exports) {

module.exports = require("moment");

/***/ }),
/* 2 */
/***/ (function(module, exports) {

module.exports = require("dotenv");

/***/ }),
/* 3 */
/***/ (function(module, exports) {

module.exports = require("rsvp");

/***/ }),
/* 4 */
/***/ (function(module, exports) {

module.exports = {
  "default": {
    interval: {
      units: 'seconds',
      value: 86400
    },
    trade: {
      minimumSize: 0.1
    }
  },
  currencies: {
    'BTC-USD': {
      sell: {},
      buy: {}
    },
    'LTC-USD': {
      sell: {},
      buy: {}
    },
    'ETH-USD': {
      sell: {},
      buy: {}
    },
    'ETH-BTC': {
      sell: {},
      buy: {}
    },
    'LTC-BTC': {
      sell: {},
      buy: {}
    }
  },
  reporting: {
    frequency: '23 hours',
    timescales: ['24 hours', '7 days', '4 weeks']
  }
};


/***/ }),
/* 5 */
/***/ (function(module, exports) {

module.exports = require("mongodb");

/***/ }),
/* 6 */
/***/ (function(module, exports) {

var BTC_PLACES, SIZE_PLACES, USD_PLACES, btc, fix, size, usd;

USD_PLACES = 2;

BTC_PLACES = 5;

SIZE_PLACES = 4;

fix = function(places, value, side) {
  var power, rootValue, roundedPower;
  power = Math.pow(10, places);
  rootValue = value * power;
  roundedPower = Math.round(rootValue) / power;
  if ('sell' === side) {
    roundedPower = Math.ceil(rootValue) / power;
  }
  if ('buy' === side) {
    roundedPower = Math.floor(rootValue) / power;
  }
  return roundedPower.toFixed(places);
};

usd = function(usd, side) {
  return fix(USD_PLACES, usd, side);
};

btc = function(btc, side) {
  return fix(BTC_PLACES, btc, side);
};

size = function(tradeSize) {
  return fix(SIZE_PLACES, tradeSize);
};

module.exports = {
  usd: usd,
  btc: btc,
  size: size
};


/***/ }),
/* 7 */
/***/ (function(module, exports, __webpack_require__) {

var Gdax, R, RSVP, authedClient, buy, cancelAllOrders, cancelOrder, clientReject, getAccounts, getFills, getOrders, getProduct24HrStats, moment, sell, stats;

__webpack_require__(2).config({
  silent: true
});

Gdax = __webpack_require__(10);

RSVP = __webpack_require__(3);

R = __webpack_require__(0);

moment = __webpack_require__(1);


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

authedClient = function() {
  var client;
  client = new Gdax.AuthenticatedClient(process.env.API_KEY, process.env.API_SECRET, process.env.API_PASSPHRASE);
  return client;
};

clientReject = function(err) {
  console.log('gdax client by error clientReject', err);
  return reinitAuthedClient();
};


/*
                __  .__               .___
  _____   _____/  |_|  |__   ____   __| _/______
 /     \_/ __ \   __\  |  \ /  _ \ / __ |/  ___/
|  Y Y  \  ___/|  | |   Y  (  <_> ) /_/ |\___ \
|__|_|  /\___  >__| |___|  /\____/\____ /____  >
      \/     \/          \/            \/    \/
 */

cancelAllOrders = function(currencies) {
  if (currencies == null) {
    currencies = [];
  }
  return new RSVP.Promise(function(resolve, reject) {
    var cancelAllCurrencyOrders, promiseCancelCurrencyOrder, rejectPromise, resolveIssues;
    promiseCancelCurrencyOrder = function(currency) {
      return new RSVP.Promise(function(resolve, reject) {
        return authedClient().cancelAllOrders({
          product_id: currency
        }, function(err, results) {
          if (err || void 0 === results) {
            console.log('cancelAllOrders.err', err);
            return reject(err);
          } else {
            return resolve(results.body);
          }
        });
      });
    };
    cancelAllCurrencyOrders = R.map(promiseCancelCurrencyOrder, currencies);
    rejectPromise = function(promise) {
      return reject(promise);
    };
    resolveIssues = function(issues) {
      return resolve(issues);
    };
    return RSVP.allSettled(cancelAllCurrencyOrders).then(resolveIssues)["catch"](rejectPromise);
  });
};

getProduct24HrStats = function(product) {
  return new RSVP.Promise(function(resolve, reject) {
    var callback, publicClient;
    publicClient = new Gdax.PublicClient(product);
    callback = function(err, json) {
      var obj;
      if (err) {
        reject(err);
      }
      obj = {};
      obj[product] = JSON.parse(json.body);
      return resolve(obj);
    };
    return publicClient.getProduct24HrStats(callback);
  });
};

stats = function(currencies) {
  if (currencies == null) {
    currencies = [];
  }
  return new RSVP.Promise(function(resolve, reject) {
    var allCurrencyStats, rejectPromise, resolveIssues;
    allCurrencyStats = R.map(getProduct24HrStats, currencies);
    rejectPromise = function(promise) {
      return reject(promise);
    };
    resolveIssues = function(issues) {
      return resolve(issues);
    };
    return RSVP.all(allCurrencyStats).then(resolveIssues)["catch"](rejectPromise);
  });
};

getAccounts = function(currency) {
  console.log(currency);
  return new RSVP.Promise(function(resolve, reject) {
    var callback;
    callback = function(err, json) {
      if (err) {
        reject(err);
      }
      return resolve(JSON.parse(json.body));
    };
    return authedClient().getAccounts(callback);
  });
};

cancelOrder = function(order) {
  return new RSVP.Promise(function(resolve, reject) {
    var callback;
    callback = function(err, data) {
      var payload;
      if (err) {
        console.log('err cancelOrder', err, order);
        reject(false);
      }
      if (!data) {
        reject(false);
      }
      payload = JSON.parse(data.body);
      if ('NotFound' === payload.message) {
        return resolve(true);
      } else {
        return reject(false);
      }
    };
    return authedClient().cancelOrder(order, callback);
  });
};

buy = function(order) {
  return new RSVP.Promise(function(resolve, reject) {
    var callback;
    callback = function(err, result) {
      if (err) {
        clientReject(err);
        reject(err);
      }
      return resolve(result);
    };
    return authedClient().buy(order, callback);
  });
};

sell = function(order) {
  return new RSVP.Promise(function(resolve, reject) {
    var callback;
    callback = function(err, result) {
      if (err) {
        reject(err);
      }
      return resolve(result);
    };
    return authedClient().sell(order, callback);
  });
};

getFills = function(product) {
  if (product == null) {
    product = product_id;
  }
  return new RSVP.Promise(function(resolve, reject) {
    return authedClient().getFills({
      product_id: product
    }, function(err, data) {
      if (err) {
        data = JSON.parse(err.body);
        console.log('err getFills', data, order);
      }
      return resolve(JSON.parse(data.body));
    });
  });
};

getOrders = function(product_id) {
  return new RSVP.Promise(function(resolve, reject) {
    var callback;
    callback = function(result) {
      console.log('result', result);
      return resolve(result);
    };
    return authedClient().getOrders(product_id, callback);
  });
};


/*                                  __
  ____ ___  _________   ____________/  |_  ______
_/ __ \\  \/  /\____ \ /  _ \_  __ \   __\/  ___/
\  ___/ >    < |  |_> >  <_> )  | \/|  |  \___ \
 \___  >__/\_ \|   __/ \____/|__|   |__| /____  >
     \/      \/|__|                           \/
 */

module.exports = {
  cancelAllOrders: cancelAllOrders,
  getProduct24HrStats: getProduct24HrStats,
  stats: stats,
  getAccounts: getAccounts,
  cancelOrder: cancelOrder,
  buy: buy,
  sell: sell,
  getFills: getFills,
  getOrders: getOrders
};


/***/ }),
/* 8 */
/***/ (function(module, exports, __webpack_require__) {

var RSVP, moment, mongo, saveFill;

__webpack_require__(2).config({
  silent: true
});

mongo = __webpack_require__(5).MongoClient;

RSVP = __webpack_require__(3);

moment = __webpack_require__(1);

saveFill = function(fill) {
  return new RSVP.Promise(function(resolve, reject) {
    return mongo.connect(process.env.MONGO_URL, function(err, db) {
      var collection;
      if (err) {
        reject(err);
      }
      collection = db.collection('fill');
      return collection.findOne({
        trade_id: fill.trade_id
      }, function(err, gee) {
        if (err) {
          reject(err);
        }
        if (gee === null) {
          console.log(fill);
          return collection.insertOne(fill, function(err, whiz) {
            if (err) {
              reject(err);
            }
            db.close();
            return resolve(fill);
          });
        } else {
          db.close();
          return resolve(true);
        }
      });
    });
  });
};

module.exports = saveFill;


/***/ }),
/* 9 */
/***/ (function(module, exports) {

module.exports = require("redux");

/***/ }),
/* 10 */
/***/ (function(module, exports) {

module.exports = require("gdax");

/***/ }),
/* 11 */
/***/ (function(module, exports) {

module.exports = require("postal");

/***/ }),
/* 12 */
/***/ (function(module, exports, __webpack_require__) {

var RSVP, currencySideRecent, moment, mongo;

__webpack_require__(2).config({
  silent: true
});

mongo = __webpack_require__(5).MongoClient;

RSVP = __webpack_require__(3);

moment = __webpack_require__(1);

currencySideRecent = function(product, side, intervalUnits, intervalLength) {
  var ago, search;
  if (intervalUnits == null) {
    intervalUnits = 1;
  }
  if (intervalLength == null) {
    intervalLength = 'hour';
  }
  ago = moment().subtract(intervalUnits, intervalLength);
  search = {
    product_id: product,
    side: side,
    time: {
      $gte: ago.toISOString()
    }
  };
  return new RSVP.Promise(function(resolve, reject) {
    var throwCurrencySideRecentError;
    throwCurrencySideRecentError = function(err) {
      console.log(err);
      return reject(err);
    };
    return mongo.connect(process.env.MONGO_URL, function(err, db) {
      var collection, foo;
      if (err) {
        throwCurrencySideRecentError(err);
      }
      collection = db.collection('matches');
      return foo = collection.find(search).toArray(function(err, docs) {
        if (err) {
          throwCurrencySideRecentError(err);
        }
        db.close();
        return resolve(docs);
      });
    });
  });
};

module.exports = currencySideRecent;


/***/ }),
/* 13 */
/***/ (function(module, exports) {

module.exports = function(code) {
  if (code == null) {
    code = 1;
  }
  console.log('exit', code);
  return process.exit(code);
};


/***/ }),
/* 14 */
/***/ (function(module, exports) {

module.exports = function() {
  var items, self;
  self = this;
  items = [];
  self.enqueue = function(item) {
    return items.push(item);
  };
  self.dequeue = function() {
    return items.shift();
  };
  self.batch = function(index) {
    if (index == null) {
      index = 100;
    }
    return items.splice(0, index);
  };
  self.peek = function() {
    return items[0];
  };
  return self;
};


/***/ }),
/* 15 */
/***/ (function(module, exports, __webpack_require__) {

var R, RSVP, moment, mongo, mongoCollection, mongoConnection, necessaryFields, saveMatches;

__webpack_require__(2).config({
  silent: true
});

R = __webpack_require__(0);

mongo = __webpack_require__(5).MongoClient;

RSVP = __webpack_require__(3);

moment = __webpack_require__(1);

necessaryFields = ['side', 'size', 'price', 'product_id', 'time', 'trade_id'];

mongoConnection = void 0;

mongoCollection = void 0;

mongo.connect(process.env.MONGO_URL, function(err, db) {
  if (err) {
    console.log('error with mongo connection', err);
  }
  mongoConnection = db;
  return mongoCollection = db.collection('matches');
});

saveMatches = function(matches) {
  return new RSVP.Promise(function(resolve, reject) {
    var details;
    details = R.map(R.pick(necessaryFields), matches);
    return mongoCollection.insert(details, function(err, whiz) {
      if (err) {
        reject(err);
      }
      return resolve(details);
    });
  });
};

module.exports = saveMatches;


/***/ }),
/* 16 */
/***/ (function(module, exports, __webpack_require__) {

var RSVP, mongo, mongoCollection, mongoConnection, necessaryFields, savePositions;

__webpack_require__(2).config({
  silent: true
});

mongo = __webpack_require__(5).MongoClient;

RSVP = __webpack_require__(3);

necessaryFields = ['side', 'size', 'price', 'product_id', 'time', 'trade_id'];

mongoConnection = void 0;

mongoCollection = void 0;

mongo.connect(process.env.MONGO_URL, function(err, db) {
  if (err) {
    console.log('error with mongo connection; savePositions', err);
  }
  mongoConnection = db;
  return mongoCollection = db.collection('positions');
});

savePositions = function(position) {
  return new RSVP.Promise(function(resolve, reject) {
    return mongoCollection.insert(position, function(err, whiz) {
      if (err) {
        reject(err);
      }
      return resolve(position);
    });
  });
};

module.exports = savePositions;


/***/ }),
/* 17 */
/***/ (function(module, exports, __webpack_require__) {

var Postal, R, Stream, river;

R = __webpack_require__(0);

Postal = __webpack_require__(11);

Stream = __webpack_require__(34);

river = Postal.channel('message');

module.exports = function(currencies) {
  var currencyStream;
  console.log(currencies);
  currencyStream = function(product) {
    var channel;
    channel = Stream(product);
    return channel.subscribe("message:" + product, function(message) {
      return river.publish("message", message);
    });
  };
  R.map(currencyStream, currencies);
  return river;
};


/***/ }),
/* 18 */
/***/ (function(module, exports) {




/***/ }),
/* 19 */
/***/ (function(module, exports, __webpack_require__) {

var R, asdf, byTime, checkObsoleteTrade, cleanUpTrades, config, defaults, halfsies, handleFractionalSize, historicalMinutes, initalState, moment, positionDetermine, predictions, pricing, projectionMinutes, reducers, redux, stategy, tooOld;

R = __webpack_require__(0);

redux = __webpack_require__(9);

moment = __webpack_require__(1);

pricing = __webpack_require__(6);

predictions = __webpack_require__(31);

cleanUpTrades = __webpack_require__(26);

checkObsoleteTrade = __webpack_require__(25);

positionDetermine = __webpack_require__(30);

halfsies = __webpack_require__(27);

handleFractionalSize = __webpack_require__(28);

stategy = __webpack_require__(33);

defaults = __webpack_require__(23);

config = __webpack_require__(4);

projectionMinutes = config["default"].interval.value;

historicalMinutes = projectionMinutes * 3;

initalState = {
  now: moment(),
  heartbeat: 0,
  currencies: {},
  prices: {},
  predictions: {},
  proposals: [],
  matches: [],
  stats: {},
  sent: [],
  orders: [],
  advice: {},
  positions: {}
};

initalState.predictions = defaults(config, {});

console.log(initalState);

byTime = function(doc) {
  return moment(doc.time).valueOf();
};

tooOld = function(doc) {
  var cutoff;
  cutoff = moment().subtract(24, 'hours');
  return moment(doc.time).isBefore(cutoff);
};

asdf = function(value, seconds) {
  var beforeCutoff, cutoff;
  cutoff = moment().subtract(value, seconds);
  beforeCutoff = function(doc) {
    return moment(doc.time).isBefore(cutoff);
  };
  return function(values) {
    return R.reject(beforeCutoff, values);
  };
};

reducers = function(state, action) {
  var asdfasdf, bestPredictions, client_oid, currency, dontOverextend, ensureMinimumSize, existingTradeCriteria, fdsa, findBestProposal, hasProjection, index, key, makeTradeProposal, order_id, proposalsToArray, side, size, start, updatePredictions, updatePredictionsByCurrencySide, validBids;
  if (typeof state === 'undefined') {
    return initalState;
  }
  state.now = moment();
  if (action.type === 'UPDATE_STATS') {
    state.stats = action.stats;
    state.advice = stategy(action.stats);
  }
  if (action.type === 'ORDER_MATCHED') {
    action.match.local = state.now.valueOf();
    key = [action.match.product_id, action.match.side].join('-').toUpperCase();
    state.prices[key] = R.pick(['time', 'price'], action.match);
    state.positions = positionDetermine(state.currencies, state.prices);
    existingTradeCriteria = function(foo) {
      return action.match.side === foo.side && action.match.product_id === foo.product_id;
    };
    index = R.findIndex(existingTradeCriteria)(state.proposals);
    if (index > 0) {
      if (checkObsoleteTrade(state.proposals[index], action.match.price)) {
        state.proposals.splice(index, 1);
      }
    }
    state.matches.push(action.match);
  }
  if (action.type === 'UPDATE_ACCOUNT') {
    state.currencies[action.currency.currency] = R.pick(['hold', 'balance'], action.currency);
    state.positions = positionDetermine(state.currencies, state.prices);
  }
  if (action.type === 'ORDER_SENT') {
    currency = action.order.product_id.split('-')[1];
    side = action.order.side;
    state.currencies[currency].hold = pricing.size(parseFloat(state.currencies[currency].hold) + parseFloat(action.order.size));
    state.currencies[currency].balance = pricing.size(parseFloat(state.currencies[currency].balance) - parseFloat(action.order.size));
    state.sent.push(action.order);
  }
  if (action.type === 'ORDER_RECEIVED') {
    client_oid = action.order.client_oid;
    if (client_oid) {
      index = R.findIndex(R.propEq('client_oid', client_oid))(state.sent);
      if (index >= 0) {
        state.orders.push(action.order);
        state.sent.splice(index, 1);
      }
    }
  }
  if (action.type === 'ORDER_FILLED') {
    order_id = action.order.order_id;
    if (order_id) {
      index = R.findIndex(R.propEq('order_id', order_id))(state.orders);
      if (index >= 0) {
        state.orders.splice(index, 1);
      }
    }
  }
  if (action.type === 'ORDER_CANCELLED') {
    order_id = action.order.order_id;
    if (order_id) {
      index = R.findIndex(R.propEq('order_id', order_id))(state.orders);
      if (index >= 0) {
        currency = action.order.product_id.split('-')[1];
        side = action.order.side;
        size = parseFloat(action.order.size);
        if ('buy' === side) {
          size = -1 * size;
        }
        state.currencies[currency].hold = pricing.size(parseFloat(state.currencies[currency].hold) - size);
        state.currencies[currency].balance = pricing.size(parseFloat(state.currencies[currency].balance) + size);
        state.orders.splice(index, 1);
      }
    }
  }
  updatePredictionsByCurrencySide = function(matches, key) {
    var byTimeFrame, day, future, hours, makePredictions, minutes, past;
    side = key.split('-')[2].toLowerCase();
    past = moment().subtract(864, 'seconds').utc().unix();
    future = moment().add(864, 'seconds').utc().unix();
    minutes = moment().subtract(864, 'seconds').utc().unix();
    hours = moment().subtract(8640, 'seconds').utc().unix();
    day = moment().subtract(86400, 'seconds').utc().unix();
    byTimeFrame = function(doc) {
      var docTime;
      docTime = moment(doc.time).utc().unix();
      if (docTime > minutes) {
        return 864;
      }
      if (docTime < minutes && docTime > hours) {
        return 8640;
      }
      return 86400;
    };
    makePredictions = function(docs) {
      var predictor;
      predictor = predictions(side, future, key);
      return predictor(docs);
    };
    return R.map(makePredictions, R.groupBy(byTimeFrame, matches));
  };
  updatePredictions = function(currencyIntents) {
    var byProductAndSide, final, finalize, foo, grouped;
    state.matches = R.sortBy(R.prop('time'), state.matches);
    byProductAndSide = function(doc) {
      return [doc.product_id, doc.side].join('-').toUpperCase();
    };
    grouped = R.groupBy(byProductAndSide, state.matches);
    foo = R.mapObjIndexed(updatePredictionsByCurrencySide, grouped);
    final = {};
    finalize = function(currencySidePair) {
      return final[currencySidePair] = foo[currencySidePair];
    };
    R.forEach(finalize, currencyIntents);
    return final;
  };
  hasProjection = function(doc) {
    return doc.linear;
  };
  proposalsToArray = function(proposal, key) {
    proposal.timeframe = key;
    return proposal;
  };
  findBestProposal = function(proposals, currencySide) {
    var doable, ordered;
    side = currencySide.split('-')[2].toLowerCase();
    if (!proposals) {
      return proposals;
    }
    doable = R.values(R.mapObjIndexed(proposalsToArray, R.filter(hasProjection, proposals)));
    ordered = R.sortBy(R.prop('linear'), doable);
    if ('sell' === side) {
      ordered = R.reverse(ordered);
    }
    return R.head(ordered);
  };
  makeTradeProposal = function(doc, key) {
    var parts;
    parts = key.split('-');
    if (doc) {
      doc.side = parts[2].toLowerCase();
      doc.product_id = [parts[0], parts[1]].join('-');
      doc.price = doc.linear;
      doc.size = halfsies(doc.current, doc.linear, state.currencies[parts[0]].balance);
    }
    return doc;
  };
  if (action.type === 'HEARTBEAT') {
    state.heartbeat = action.message;
    start = moment().valueOf();
    asdfasdf = function(a, b) {
      var asdfasdfasdf;
      asdfasdfasdf = function(c) {
        return [b, c].join('-').toUpperCase();
      };
      return R.map(asdfasdfasdf, R.keys(a));
    };
    state.predictions = updatePredictions(R.uniq(R.flatten(R.values(R.mapObjIndexed(asdfasdf, state.advice)))));
    bestPredictions = R.reject(R.isNil, R.values(R.mapObjIndexed(makeTradeProposal, R.mapObjIndexed(findBestProposal, state.predictions))));
    fdsa = function(doc) {
      return handleFractionalSize(doc, 0.01);
    };
    dontOverextend = R.filter(fdsa, bestPredictions);
    ensureMinimumSize = function(doc) {
      if (doc.size < 0.01) {
        doc.size = 0.01;
      }
      return doc;
    };
    validBids = R.map(ensureMinimumSize, dontOverextend);
    state.proposals = R.map(cleanUpTrades, validBids);
    console.log('HEARTBEAT', moment().valueOf() - start, 'ms');
  }
  return state;
};

module.exports = reducers;


/***/ }),
/* 20 */
/***/ (function(module, exports, __webpack_require__) {

var INTERVAL, R, cantSaveFills, config, gdax, getCurrencyFills, moment, saveFill, saveFills, throttledDispatchFill;

R = __webpack_require__(0);

moment = __webpack_require__(1);

gdax = __webpack_require__(7);

saveFill = __webpack_require__(8);

config = __webpack_require__(4);

INTERVAL = 100;

throttledDispatchFill = function(match, index) {
  var orNot, sendThrottledDispatchFill, wereGood;
  if (index == null) {
    index = 0;
  }
  wereGood = function(result) {
    var since;
    since = moment(match.created_at).fromNow(true);
    if (result === true) {
      return console.log('$', since);
    } else {
      return console.log('+', since);
    }
  };
  orNot = function(result) {
    console.log('orNot', result);
    return exit(3);
  };
  sendThrottledDispatchFill = function() {
    return saveFill(match).then(wereGood)["catch"](orNot);
  };
  return setTimeout(sendThrottledDispatchFill, (index * INTERVAL) + (Math.random() * INTERVAL));
};

saveFills = function(fills) {
  var mapIndexed;
  mapIndexed = R.addIndex(R.map);
  return mapIndexed(throttledDispatchFill, fills);
};

cantSaveFills = function(fills) {
  return console.log('cantSaveFills', fills);
};

getCurrencyFills = function(product_id) {
  return gdax.getFills(product_id).then(saveFills)["catch"](cantSaveFills);
};

module.exports = function() {
  return R.map(getCurrencyFills, R.keys(config.currencies));
};


/***/ }),
/* 21 */
/***/ (function(module, exports) {

module.exports = require("deep-equal");

/***/ }),
/* 22 */
/***/ (function(module, exports) {

module.exports = require("redux-thunk");

/***/ }),
/* 23 */
/***/ (function(module, exports, __webpack_require__) {

var R, config;

R = __webpack_require__(0);

config = __webpack_require__(4);

module.exports = function(config, defaultValue) {
  var createKeys;
  if (defaultValue == null) {
    defaultValue = {};
  }
  createKeys = function(values, currency) {
    var addCurrency, obj;
    obj = {};
    addCurrency = function(defaults, side) {
      var key;
      key = [currency, side].join('-').toUpperCase();
      obj = {};
      obj[key] = defaultValue;
      return obj;
    };
    return R.mergeAll(R.values(R.mergeAll(R.mapObjIndexed(addCurrency, values))));
  };
  return R.mergeAll(R.values(R.mapObjIndexed(createKeys, config.currencies)));
};


/***/ }),
/* 24 */
/***/ (function(module, exports, __webpack_require__) {

var INTERVAL, Queue, R, Streams, applyMiddleware, asdfasdf, channel, clearOutOldOrders, config, createStore, currencySideRecent, deepEqual, dispatchMatch, exit, gdax, getRelevantCurrencies, historicalMinutes, hydrateRecentCurrency, makeNewTrades, matchesQueue, ml, moment, orderFailed, orderSuccess, projectionMinutes, reducers, ref, saveAccountPositions, saveFill, saveFills, saveMatches, savePosition, sendHeartbeat, showAccounts, showSavedMatch, store, throttledDispatchMatch, thunk, universalBad, updateAccounts, updateStats, updatedStore, waitAMoment;

__webpack_require__(2).config({
  silent: true
});

R = __webpack_require__(0);

moment = __webpack_require__(1);

thunk = __webpack_require__(22);

deepEqual = __webpack_require__(21);

gdax = __webpack_require__(7);

currencySideRecent = __webpack_require__(12);

saveFill = __webpack_require__(8);

savePosition = __webpack_require__(16);

Streams = __webpack_require__(17);

config = __webpack_require__(4);

ml = __webpack_require__(18);

exit = __webpack_require__(13);

projectionMinutes = config["default"].interval.value;

console.log(projectionMinutes);

historicalMinutes = projectionMinutes * 5;

reducers = __webpack_require__(19);

ref = __webpack_require__(9), createStore = ref.createStore, applyMiddleware = ref.applyMiddleware;

store = createStore(reducers, applyMiddleware(thunk["default"]));

orderSuccess = function(response) {
  var body;
  body = JSON.parse(response.body);
  if (body.message) {
    return console.log('orderSuccess', response.body);
  }
};

orderFailed = function(order) {
  console.log('orderFailed', order);
  return exit();
};

updatedStore = function() {
  var important, keys, state;
  state = store.getState();
  keys = ['positions'];
  important = R.pick(keys, state);
  return console.log(moment().format(), 'we got this', '$', important.positions.total.totalUSD.toFixed(2));
};

setInterval(updatedStore, 59 * 1000);


/*
_________                            .__
\_   ___ \_____    ____   ____  ____ |  |
/    \  \/\__  \  /    \_/ ___\/ __ \|  |
\     \____/ __ \|   |  \  \__\  ___/|  |__
 \______  (____  /___|  /\___  >___  >____/
        \/     \/     \/     \/    \/
________            .___
\_____  \_______  __| _/___________  ______
 /   |   \_  __ \/ __ |/ __ \_  __ \/  ___/
/    |    \  | \/ /_/ \  ___/|  | \/\___ \
\_______  /__|  \____ |\___  >__|  /____  >
        \/           \/    \/           \/
 */

clearOutOldOrders = function() {
  var cancelOrder, expired, state, tooOld;
  state = store.getState();
  cancelOrder = function(order) {
    var cancelOrderFailed, cancelOrderSuccess;
    cancelOrderSuccess = function(response) {
      console.log('cancelOrderSuccess', response, order.order_id);
      return store.dispatch({
        type: 'ORDER_CANCELLED',
        order: order
      });
    };
    cancelOrderFailed = function(status) {};
    return gdax.cancelOrder(order.order_id).then(cancelOrderSuccess)["catch"](cancelOrderFailed);
  };
  tooOld = function(order) {
    return moment(order.time).isBefore(moment().subtract(864, 'seconds'));
  };
  expired = R.filter(tooOld, state.orders);
  if (expired.length > 0) {
    console.log('cancel', R.pluck('order_id', expired));
    return R.map(cancelOrder, expired);
  }
};

clearOutOldOrders();

setInterval(clearOutOldOrders, (864 * 1000) / 10);

gdax.cancelAllOrders(R.keys(config.currencies)).then(function(result) {
  return console.log(result);
});


/*
___________                  .___
\__    ___/___________     __| _/____   ______
  |    |  \_  __ \__  \   / __ |/ __ \ /  ___/
  |    |   |  | \// __ \_/ /_/ \  ___/ \___ \
  |____|   |__|  (____  /\____ |\___  >____  >
                      \/      \/    \/     \/
                      Trades
 */

makeNewTrades = function() {
  var buyOrder, bySide, important, keys, predictionResults, sellOrder, sides, state;
  state = store.getState();
  keys = ['orders', 'proposals'];
  important = R.pick(keys, state);
  predictionResults = R.values(R.pick(['predictions'], state));
  bySide = function(trade) {
    return trade.side;
  };
  sides = R.groupBy(bySide, state.proposals);
  console.log(sides);
  sellOrder = function(order) {
    store.dispatch({
      type: 'ORDER_SENT',
      order: order
    });
    return gdax.sell(order).then(orderSuccess)["catch"](orderFailed);
  };
  buyOrder = function(order) {
    store.dispatch({
      type: 'ORDER_SENT',
      order: order
    });
    return gdax.buy(order).then(orderSuccess)["catch"](orderFailed);
  };
  if (sides.sell) {
    R.map(sellOrder, sides.sell);
  }
  if (sides.buy) {
    return R.map(buyOrder, sides.buy);
  }
};

setInterval(makeNewTrades, (864 * 1000) / 10);

universalBad = function(err) {
  console.log('bad', err);
  if (err) {
    throw err;
  }
  return exit();
};


/*
   _____                                   __
  /  _  \   ____  ____  ____  __ __  _____/  |_
 /  /_\  \_/ ___\/ ___\/  _ \|  |  \/    \   __\
/    |    \  \__\  \__(  <_> )  |  /   |  \  |
\____|__  /\___  >___  >____/|____/|___|  /__|
        \/     \/    \/                 \/
        Update Account info
 */

getRelevantCurrencies = function(currencyPairs) {
  var split;
  split = function(currencyPair) {
    return currencyPair.split('-');
  };
  return R.uniq(R.flatten(R.map(split, currencyPairs)));
};

showAccounts = function(results) {
  var currentlyTraded, currentlyTradedCurrencies, dispatchCurrencyBalance;
  currentlyTradedCurrencies = getRelevantCurrencies(R.keys(config.currencies));
  currentlyTraded = function(result) {
    return R.contains(result.currency, currentlyTradedCurrencies);
  };
  dispatchCurrencyBalance = function(currency) {
    return store.dispatch({
      type: 'UPDATE_ACCOUNT',
      currency: currency
    });
  };
  return R.map(dispatchCurrencyBalance, R.map(R.pick(['currency', 'hold', 'balance']), R.filter(currentlyTraded, results)));
};

updateAccounts = function() {
  return gdax.getAccounts().then(showAccounts);
};

updateAccounts();

setInterval(updateAccounts, 15 * 60 * 1000);

saveAccountPositions = function() {
  var now, position;
  now = moment();
  position = store.getState().positions;
  position.time = now.toISOString();
  return savePosition(position).then(function(result) {
    return console.log(result, now.format());
  });
};

setTimeout(saveAccountPositions, 1 * 5 * 1000);

setInterval(saveAccountPositions, 15 * 60 * 1000);


/*
   _____          __         .__
  /     \ _____ _/  |_  ____ |  |__   ____   ______
 /  \ /  \\__  \\   __\/ ___\|  |  \_/ __ \ /  ___/
/    Y    \/ __ \|  | \  \___|   Y  \  ___/ \___ \
\____|__  (____  /__|  \___  >___|  /\___  >____  >
        \/     \/          \/     \/     \/     \/
 */

Queue = __webpack_require__(14);

matchesQueue = Queue();

saveMatches = __webpack_require__(15);

dispatchMatch = function(match, save) {
  if (save == null) {
    save = true;
  }
  store.dispatch({
    type: 'ORDER_MATCHED',
    match: match
  });
  if (save) {
    return matchesQueue.enqueue(match);
  }
};

showSavedMatch = function(result) {
  var info;
  info = JSON.stringify(R.pick(['time', 'product_id', 'side', 'price', 'size', 'trade_id'], result));
  return console.log('+', info);
};

asdfasdf = function() {
  var matches, saveFillFailure, saveFillSuccess;
  matches = matchesQueue.batch();
  if (0 !== matches.length) {
    saveFillSuccess = function(results) {};
    saveFillFailure = function(err) {
      console.log('errrrrrr asdfasdf', err);
      matchesQueue.enqueue(match);
      return exit();
    };
    return saveMatches(matches).then(saveFillSuccess)["catch"](saveFillFailure);
  }
};

setInterval(asdfasdf, 6000);

sendHeartbeat = function() {
  return store.dispatch({
    type: 'HEARTBEAT',
    message: moment().valueOf()
  });
};

setInterval(sendHeartbeat, 30 * 1000);

channel = Streams(R.keys(config.currencies));

channel.subscribe('message', function(message) {
  if (message.type === 'match') {
    dispatchMatch(message);
  }
  if (message.type === 'received') {
    store.dispatch({
      type: 'ORDER_RECEIVED',
      order: message
    });
  }
  if (message.type === 'done' && message.reason === 'filled') {
    return store.dispatch({
      type: 'ORDER_FILLED',
      order: message
    });
  }
});


/*
  ___ ___            .___              __
 /   |   \ ___.__. __| _/___________ _/  |_  ____
/    ~    <   |  |/ __ |\_  __ \__  \\   __\/ __ \
\    Y    /\___  / /_/ | |  | \// __ \|  | \  ___/
 \___|_  / / ____\____ | |__|  (____  /__|  \___  >
       \/  \/         \/            \/          \/
 */

INTERVAL = 10;

throttledDispatchMatch = function(match, index) {
  var sendThrottledDispatchMatch;
  sendThrottledDispatchMatch = function() {
    return dispatchMatch(match, false);
  };
  return setTimeout(sendThrottledDispatchMatch, (index * INTERVAL) + (Math.random() * INTERVAL));
};

hydrateRecentCurrency = function(product_id) {
  var hydrateRecentCurrencySide;
  hydrateRecentCurrencySide = function(side) {
    return currencySideRecent(product_id, side, 86400, 'seconds').then(function(matches) {
      var even, mapIndexed, odd, v;
      odd = (function() {
        var i, len, results1;
        results1 = [];
        for (i = 0, len = matches.length; i < len; i += 2) {
          v = matches[i];
          results1.push(v);
        }
        return results1;
      })();
      even = (function() {
        var i, len, ref1, results1;
        ref1 = matches.slice(1);
        results1 = [];
        for (i = 0, len = ref1.length; i < len; i += 2) {
          v = ref1[i];
          results1.push(v);
        }
        return results1;
      })();
      mapIndexed = R.addIndex(R.map);
      return mapIndexed(throttledDispatchMatch, odd.concat(R.reverse(even)));
    });
  };
  return R.map(hydrateRecentCurrencySide, ['sell', 'buy']);
};

waitAMoment = function() {
  return R.map(hydrateRecentCurrency, R.keys(config.currencies));
};

setTimeout(waitAMoment, 1000);


/*
  _________ __          __
 /   _____//  |______ _/  |_  ______
 \_____  \\   __\__  \\   __\/  ___/
 /        \|  |  / __ \|  |  \___ \
/_______  /|__| (____  /__| /____  >
        \/           \/          \/
 */

updateStats = function() {
  var dispatchStats;
  dispatchStats = function(results) {
    return store.dispatch({
      type: 'UPDATE_STATS',
      stats: R.mergeAll(results)
    });
  };
  return gdax.stats(R.keys(config.currencies)).then(dispatchStats);
};

updateStats();

setInterval(updateStats, 30 * 1000);


/*
__________                             ___.
\______   \ ____   _____   ____   _____\_ |__   ___________
 |       _// __ \ /     \_/ __ \ /     \| __ \_/ __ \_  __ \
 |    |   \  ___/|  Y Y  \  ___/|  Y Y  \ \_\ \  ___/|  | \/
 |____|_  /\___  >__|_|  /\___  >__|_|  /___  /\___  >__|
        \/     \/      \/     \/      \/    \/     \/
 */

saveFills = __webpack_require__(20);

setTimeout(saveFills, 2000);

setInterval(saveFills, 1000 * 60 * 15);

process.on('uncaughtException', function(err) {
  return console.log('Caught exception: ' + err);
});


/***/ }),
/* 25 */
/***/ (function(module, exports) {

var checkObsoleteTrade;

checkObsoleteTrade = function(trade, price) {
  var newPrice, tradePrice;
  tradePrice = parseFloat(trade.price);
  newPrice = parseFloat(price);
  if (trade.side === 'sell') {
    if (tradePrice > newPrice) {
      return false;
    }
  }
  if (trade.side === 'buy') {
    if (tradePrice < newPrice) {
      return false;
    }
  }
  return true;
};

module.exports = checkObsoleteTrade;


/***/ }),
/* 26 */
/***/ (function(module, exports, __webpack_require__) {

var cleanUpTrades, pricing, uuid;

uuid = __webpack_require__(36);

pricing = __webpack_require__(6);

cleanUpTrades = function(trade) {
  var priceFormat;
  priceFormat = trade.product_id.split('-')[1];
  if ('USD' === priceFormat) {
    trade.price = pricing.usd(trade.price, trade.side);
  }
  if ('BTC' === priceFormat) {
    trade.price = pricing.btc(trade.price, trade.side);
  }
  if (!trade.client_oid) {
    trade.client_oid = uuid.v4();
  }
  trade.size = pricing.size(trade.size);
  return trade;
};

module.exports = cleanUpTrades;


/***/ }),
/* 27 */
/***/ (function(module, exports, __webpack_require__) {

var MINIMUM_AMOUNT, halfsies, max;

max = __webpack_require__(0).max;


/*
TODO REFACTOR
currently we could return zero if we hold zero crypto
this returns an amount that should statistically
lead to a trade every 10 tries

there needs to be a better way to do this
 */

MINIMUM_AMOUNT = 0.001;

halfsies = function(current, projected, amount) {
  var currentValue, newAmount;
  currentValue = parseFloat(current) * parseFloat(amount);
  newAmount = currentValue / parseFloat(projected);
  return max(MINIMUM_AMOUNT, Math.abs(amount - newAmount) / 2.0);
};

module.exports = halfsies;


/***/ }),
/* 28 */
/***/ (function(module, exports) {


/*
Handle Fractional Sizes

the actual size of a bid may be lower than the minimum allowable size for that currency pair

if the ratio of that discrepency, actual vs minumum, is greater than a randomly generated value, let it happen
 */
var handleFractionalSize;

handleFractionalSize = function(bid, minimumSize, randomNumber) {
  if (randomNumber == null) {
    randomNumber = Math.random();
  }
  return (bid.size / minimumSize) > randomNumber;
};

module.exports = handleFractionalSize;


/***/ }),
/* 29 */
/***/ (function(module, exports, __webpack_require__) {

var R, docToCartesian, matchesToCartesian, moment, reduceToFirstPriceOccurence, reduceToLastPriceOccurence;

R = __webpack_require__(0);

moment = __webpack_require__(1);

docToCartesian = function(doc) {
  var x, y;
  x = moment(doc.time).unix();
  y = parseFloat(doc.price);
  return [x, y];
};

reduceToFirstPriceOccurence = function(accumulator, value) {
  var last;
  if (accumulator == null) {
    accumulator = [];
  }
  last = R.last(accumulator);
  if (last === void 0) {
    last = value;
    accumulator.push(last);
  }
  if (last[1] !== value[1] && last[0] !== value[0]) {
    accumulator.push(value);
  }
  return accumulator;
};

reduceToLastPriceOccurence = function(accumulator, value) {
  var last;
  if (accumulator == null) {
    accumulator = [];
  }
  last = R.last(accumulator);
  if (last === void 0) {
    last = value;
    accumulator.push(last);
    return accumulator;
  }
  if (last[1] === value[1] || last[0] === value[0]) {
    accumulator = R.dropLast(1, accumulator);
  }
  accumulator.push(value);
  return accumulator;
};

matchesToCartesian = function(docs, countAtEnd) {
  var mappedDocs;
  if (countAtEnd == null) {
    countAtEnd = false;
  }
  mappedDocs = R.map(docToCartesian, docs);
  if (countAtEnd === false) {
    return R.reduce(reduceToFirstPriceOccurence, [], mappedDocs);
  } else {
    return R.reduce(reduceToLastPriceOccurence, [], mappedDocs);
  }
};

module.exports = matchesToCartesian;


/***/ }),
/* 30 */
/***/ (function(module, exports, __webpack_require__) {

var defaultCurrency, mapObjIndexed, pluck, positionDetermine, ref, sum, values;

ref = __webpack_require__(0), mapObjIndexed = ref.mapObjIndexed, values = ref.values, pluck = ref.pluck, sum = ref.sum;

defaultCurrency = {
  price: 1
};

positionDetermine = function(balances, prices) {
  var current, findPositionForCurrency, sumTotals;
  if (!balances && !prices) {
    return {};
  }
  findPositionForCurrency = function(foo, currency) {
    var currencyBalance, currencyPrice, result;
    result = {};
    currencyBalance = balances[currency];
    currencyPrice = prices[currency + "-USD-SELL"] || defaultCurrency;
    foo.holdUSD = parseFloat((currencyPrice.price || 1) * currencyBalance.hold).toFixed(2);
    foo.balanceUSD = parseFloat((currencyPrice.price || 1) * currencyBalance.balance).toFixed(2);
    return foo;
  };
  current = mapObjIndexed(findPositionForCurrency, balances);
  sumTotals = function(individualTotals) {
    var individualValues, total;
    individualValues = values(individualTotals);
    return total = {
      holdUSD: sum(pluck('holdUSD', individualValues)),
      balanceUSD: sum(pluck('balanceUSD', individualValues))
    };
  };
  current.total = sumTotals(current);
  current.total.totalUSD = current.total.holdUSD + current.total.balanceUSD;
  return current;
};

module.exports = positionDetermine;


/***/ }),
/* 31 */
/***/ (function(module, exports, __webpack_require__) {

var R, linearLast, matchesToCartesian, moment, pricing, regression;

regression = __webpack_require__(35);

R = __webpack_require__(0);

moment = __webpack_require__(1);

matchesToCartesian = __webpack_require__(29);

pricing = __webpack_require__(6);

linearLast = function(docs, future, base) {
  var coords, equation, last;
  last = R.last(docs);
  if (!last) {
    return {};
  }
  coords = matchesToCartesian(docs, true);
  coords.push([future, null]);
  equation = regression('linear', coords);
  return R.last(equation.points)[1];
};

module.exports = function(side, future, key) {
  var base;
  base = key.split('-')[1].toLowerCase();
  return function(results) {
    var a, equations, isMyGoodSide, last, linearLastResults;
    last = R.last(results);
    isMyGoodSide = function(value) {
      if ('sell' === side) {
        return value > last.price;
      }
      if ('buy' === side) {
        return value < last.price;
      }
    };
    equations = {};
    equations.n = results.length;
    if (results.length <= 3) {
      return equations;
    }
    linearLastResults = linearLast(results, future, base);
    if (linearLastResults && isMyGoodSide(linearLastResults) && !isNaN(linearLastResults)) {
      equations.linear = linearLastResults;
    } else {
      return a = {
        n: results.length
      };
    }
    equations.future = future;
    equations.current = pricing[base](last.price);
    return equations;
  };
};


/***/ }),
/* 32 */
/***/ (function(module, exports) {

module.exports = function(status) {
  if (status == null) {
    status = 42;
  }
  console.log('PROCESS RESTART NOW', status);
  return process.exit(status);
};


/***/ }),
/* 33 */
/***/ (function(module, exports, __webpack_require__) {

var all, buyAdvice, equals, filter, keys, lastIsHigherThanOpen, map, merge, pick, ref, sellAdvice, tradesAgainstUSD, values;

ref = __webpack_require__(0), keys = ref.keys, filter = ref.filter, pick = ref.pick, values = ref.values, all = ref.all, map = ref.map, merge = ref.merge, equals = ref.equals;

tradesAgainstUSD = function(product) {
  var parts;
  parts = product.split('-');
  return parts[1] === 'USD';
};

lastIsHigherThanOpen = function(stats) {
  return parseFloat(stats.last) > parseFloat(stats.open);
};

buyAdvice = {
  buy: {}
};

sellAdvice = {
  sell: {}
};

module.exports = function(stats) {
  var asdf, currentAdvice, gee, makeProductAdvice, shouldWeSell, usdProducts, usdStats;
  usdProducts = filter(tradesAgainstUSD, keys(stats));
  usdStats = pick(usdProducts, stats);
  shouldWeSell = all(equals(true), values(map(lastIsHigherThanOpen, usdStats)));
  asdf = true === shouldWeSell ? sellAdvice : buyAdvice;
  makeProductAdvice = function() {
    return asdf;
  };
  currentAdvice = map(makeProductAdvice, usdStats);
  gee = {
    'BTC-USD': {
      sell: {},
      buy: {}
    },
    'LTC-USD': {
      sell: {},
      buy: {}
    },
    'ETH-USD': {
      sell: {},
      buy: {}
    },
    'ETH-BTC': {
      sell: {},
      buy: {}
    },
    'LTC-BTC': {
      sell: {},
      buy: {}
    }
  };
  return merge(gee, currentAdvice);
};


/***/ }),
/* 34 */
/***/ (function(module, exports, __webpack_require__) {

var Gdax, Postal, authentication, restart;

__webpack_require__(2).config({
  silent: true
});

Postal = __webpack_require__(11);

Gdax = __webpack_require__(10);

restart = __webpack_require__(32);

authentication = {
  secret: process.env.API_SECRET,
  key: process.env.API_KEY,
  passphrase: process.env.API_PASSPHRASE
};

module.exports = function(product) {
  var channel, start;
  if (product == null) {
    product = 'BTC-USD';
  }
  channel = Postal.channel('websocket');
  start = function() {
    var websocket;
    websocket = new Gdax.WebsocketClient(product, null, authentication);
    websocket.on('open', function() {
      return console.log("OPEN " + product + " WEBSOCKET!!!");
    });
    websocket.on('close', function() {
      console.log("CLOSE " + product + " WEBSOCKET!!!");
      return setTimeout(start, 10000);
    });
    return websocket.on('message', function(message) {
      return channel.publish("message:" + product, message);
    });
  };
  start();
  return channel;
};


/***/ }),
/* 35 */
/***/ (function(module, exports) {

module.exports = require("regression");

/***/ }),
/* 36 */
/***/ (function(module, exports) {

module.exports = require("uuid");

/***/ })
/******/ ]);