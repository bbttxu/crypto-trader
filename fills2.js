/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

const SIZE_ZERO = "0.00000000";

const config = require("./config");

const { hash, all, Promise } = require("rsvp");

const {
  keys,
  take,
  map,
  length,
  pluck,
  groupBy,
  prop,
  sortBy,
  pick,
  where,
  __,
  lt,
  gt,
  filter,
  addIndex,
  sum,
  reject,
  uniq,
  // all,
  equals,
  zip,
  flatten,
  forEach,
  contains
} = require("ramda");

// const reconcile = require("./lib/reconciler");
const Redis = require("ioredis");

const moment = require("moment");

const { createStore, applyMiddleware, combineReducers } = require("redux");

const thunk = require("redux-thunk");

const fillsReducer = require("./reducers/fills");
// reducers.fills = fillsReducer

// rootReducer = combineReducers reducers
const store = createStore(fillsReducer, applyMiddleware(thunk.default));

const { getFills, getAccounts } = require("./lib/gdax-client");

let shuffle = require("knuth-shuffle").knuthShuffle;

let currencies = keys(config.currencies);
currencies = take(1, shuffle(currencies));

console.log(currencies);

const whatWasOneDayAgo = moment().subtract(1, "day");
const whatYearWasItADayAgo = whatWasOneDayAgo.year();
const areWeInTheYearWeCareAbout = equals(whatYearWasItADayAgo);

console.log(whatYearWasItADayAgo);

const mapIndex = addIndex(map);

const tradeChannel = new Redis();

// const reconcileBuysWithSells = (incomingBuys, incomingSells) => {
//   const split = groupBy(prop("side"), trades);

//   const buys = incomingBuys;
//   const sells = incomingSells;

//   console.log(incomingBuys, incomingSells);
//   let values = [];

//   const findSale = (notused, buyIndex) => {
//     console.log("buy", buyIndex);
//     const buy = buys[buyIndex];

//     const reconcileBuyWithSell = (sell, sellIndex) => {
//       console.log("sell", sellIndex);

//       const a = reconcile(buy, sell);
//       // console.log a

//       buys[buyIndex] = a[0];
//       // console.log 'buys', buys

//       sells[sellIndex] = a[1];
//       values = values.concat(a[2]);

//       // console.log values.sort()
//       return a;
//     };

//     return mapIndex(reconcileBuyWithSell, sells);
//   };

//   // console.log 'sells', sells

//   mapIndex(findSale, buys);

//   return {
//     buys,
//     sells,
//     value: sum(values)
//   };
// };

shuffle = require("knuth-shuffle").knuthShuffle;
// saveFill = require './lib/saveFill'
const { addFillToQueue } = require("./workers/saveFillToStorage");

const addFill = fill => {
  store.dispatch({
    type: "FILLS_ADDS",
    fill
  });
  // console.log fill
  return fill;
};

const getYearFromDate = date => moment(date).year();

// getAccounts().then( console.log );

// const getFillsFromStorage = require("./lib/getFills");
const getBuyFillsFromStorage = require("./lib/getBuyFills");
const getSellFillsFromStorage = require("./lib/getSellFills");

const getAllCurrentYearFillsFor = currency => {
  return new Promise((resolve, rejectPromise) => {
    hash({
      buys: getBuyFillsFromStorage(currency),
      sells: getSellFillsFromStorage(currency)
    })
      .then(({ sells, buys }) => {
        return zip(sells, buys);
      })
      .then(flatten)
      .then(uniq)
      .then(resolve)
      .catch(rejectPromise);
  });
};

const handleCurrency = (currency, params = {}) => {
  const addTrade = trade => {
    tradeChannel.publish("trade:" + currency, JSON.stringify(trade));
  };

  const getAllCurrentYearFillsForCurrency = getAllCurrentYearFillsFor(currency);

  getAllCurrentYearFillsForCurrency
    // FEED trades into the reducer to
    .then(trades => {
      forEach(addTrade, trades);
      return trades;
    })
    .then(pluck("trade_id"))
    .then(results => {
      // console.log(results);
      return results;
    });

  hash({
    current: getAllCurrentYearFillsForCurrency,
    fillsFromExchange: getFills(currency, params)
  })
    .then(({ current, fillsFromExchange }) => {
      const trade_ids = pluck("trade_id", current);

      return reject(({ trade_id }) => {
        return contains(trade_id, trade_ids);
      }, fillsFromExchange);
    })
    .then(shuffle)
    // .then(take(2))
    .then(map(addFillToQueue))
    .then(length)
    .then(console.log)
    .catch(console.error);
  // ).then(
  // FEED trades into the reducer to
  // const updateFillsFromSource = (currency, params) => {
  //   getFills(currency, params)
  //     // .then( sortBy prop( 'price' ) )
  //     // .then(shuffle)
  //     // .then(take(5))
  //     // ).then(
  //     //   map pick( ['price', 'size', 'side', 'created_at', 'trade_id'])
  //     .then(map(addFillToQueue))
  //     // .then( RSVP.all )
  //     .then(fills => {
  //       const dates = pluck("created_at", fills).sort();

  //       const years = uniq(map(getYear  //   getFills(currency, params)
  //     // .then( sortBy prop( 'price' ) )
  //     // .then(shuffle)
  //     // .then(take(5))
  //     // ).then(
  //     //   map pick( ['price', 'size', 'side', 'created_at', 'trade_id'])
  //     .then(map(addFillToQueue))
  //     // .then( RSVP.all )
  //     .then(fills => {
  //       const dates = pluck("created_at", fills).sort();

  //       const years = uniq(map(getYearFromDate, dates));
  //       console.log(years, dates[0]);

  //       if (all(areWeInTheYearWeCareAbout, years)) {
  //         const foo = () =>
  //           updateFillsFromSource(currency, {
  //             after: pluck("trade_id", fills).sort()[0]
  //           });

  //         setTimeout(foo, 1000 * currencies.length);
  //       }

  //       // console.log fills.length
  //       return fills;
  //     })
  //     .catch(console.log)
  //     .finally(() => console.log("finally", currency, params));
  // };
  // updateFillsFromSource(currency);FromDate, dates));
  //       console.log(years, dates[0]);

  //       if (all(areWeInTheYearWeCareAbout, years)) {
  //         const foo = () =>
  //           updateFillsFromSource(currency, {
  //             after: pluck("trade_id", fills).sort()[0]
  //           });

  //         setTimeout(foo, 1000 * currencies.length);
  //       }

  //       // console.log fills.length
  //       return fills;
  //     })
  //     .catch(console.log)
  //     .finally(() => console.log("finally", currency, params));
  // };
  // updateFillsFromSource(currency);
};
map(handleCurrency, currencies);

// saveFills = require('./save2')(config)

// saveFills()
// setInterval saveFills, (1000 * 60 * 10)
