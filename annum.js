const { currencies } = require("./config");

const {
  keys,
  take,
  groupBy,
  prop,
  map,
  sortBy,
  findIndex,
  where,
  gte,
  equals,
  pluck,
  pick,
  addIndex,
  remove,
  lte,
  sum,
  reject
} = require("ramda");
// import { keys } from "ramda";

const getFills = require("./lib/getFills");

const { hash } = require("rsvp");
// const {}

const gains = require("./lib/gains");

const importantValues = pick(["size", "price", "created_at"]);

rejectZeroSize = obj => {
  // console.log(obj.size);
  return obj.size === "0.00000000";
};

const getFillForProductId = product_id =>
  hash({
    buys: getFills(product_id, "buy"),
    sells: getFills(product_id, "sell")
  })
    .then(map(sortBy(prop("created_at"))))
    // getFills(product_id)
    // .then(take(100))
    // .then(groupBy(prop("side")))
    .then(sides => {
      // console.log(sides);
      let { buys, sells } = sides;

      let values = [];

      // console.log("buy", buys.length);
      // console.log("sell", sells.length);

      const matchSells = (buy, i) => {
        // console.log(importantValues(buy));

        viableSell = where({
          size: equals(buy.size),
          price: lte(buy.price)
        });

        const index = findIndex(viableSell, sells);
        // console.log(index, i);

        if (index > -1) {
          const valuations = gains(buy, sells[index]);
          // console.log(valuations);
          // sells[index] = undefined;

          sells[index] = valuations.sell;
          values.push(valuations.value);
          // sells = remove(index, 1, sells);
          return valuations.buy;
        }

        return buy;
      };

      buys = addIndex(map)(matchSells, buys);
      // console.log(buys);
      // console.log(map(importantValues, sells));
      return {
        sells,
        buys,
        values
      };
    })
    .then(({ sells, buys, values }) => {
      // Only report
      const volume = sum(map(parseFloat, pluck("size", values)));
      const earnings = sum(map(parseFloat, pluck("base", values)));
      console.log("ratio", (earnings / volume - 100) / 100, "on", volume);

      return {
        sells,
        buys,
        values
      };
    })
    .then(({ sells, buys, values }) => {
      // Only report
      const volume = sum(map(parseFloat, pluck("size", buys)));
      // const earnings = sum(map(parseFloat, pluck("base", buys)));
      console.log("invested", volume);

      return {
        sells,
        buys,
        values
      };
    })
    .then(({ sells, buys, values }) => {
      // Only report
      const volume = sum(map(parseFloat, pluck("size", sells)));
      // const earnings = sum(map(parseFloat, pluck("base", buys)));
      console.log("outvested", volume);

      return {
        sells,
        buys,
        values
      };
    })
    .then(({ sells, buys, values }) => {
      console.log(buys.length);
      console.log(sells.length);

      buys = reject(rejectZeroSize, buys);
      // sells = map(rejectZeroSize, sells);

      console.log("b", buys.length);
      // console.log(sells.length);
      return {
        sells,
        buys,
        values
      };
    })
    .then(({ sells, buys, values }) => {
      // console.log(buys.length);
      // console.log(sells.length);

      // buys = reject(rejectZeroSize, buys);
      sells = map(rejectZeroSize, sells);

      // console.log("b", buys.length);
      console.log("c", sells.length);
      return {
        sells,
        buys,
        values
      };
    })
    .catch(console.log);

keys(currencies).map(getFillForProductId);
// console.log(keys(currencies));
// getFills(keys(currencies)).then(console.info).catch(console.log);
// // // currencies = take 1, shuffle currencies
