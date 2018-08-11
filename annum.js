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
  reject,
  flatten,
  keys,
  mergeAll,
  propEq,
  reverse
} = require("ramda");
// import { keys } from "ramda";

const getFills = require("./lib/getFills");

const { hash } = require("rsvp");
// const {}
var i = 0;
const logAndReturn = foo => {
  console.log(++i, foo);
  return foo;
};

const gains = require("./lib/gains");

const getValues = require("./lib/assessValues");

const asdf = ({ sell = [], buy = [] }) => {
  // console.log(sell, buy);

  let value = [];

  const matchSells = (indexedBuy, i) => {
    viableSell = where({
      size: equals(indexedBuy.size),
      price: lte(indexedBuy.price)
    });

    const index = findIndex(viableSell, sell);

    if (index > -1) {
      const valuations = gains(indexedBuy, sell[index]);
      // console.log(valuations);
      indexedBuy.size = valuations.sell.size;
      sell[index] = valuations.sell;
      value.push(valuations.value);
      return valuations.indexedBuy;
    }

    return indexedBuy;
  };

  buys = addIndex(map)(matchSells, buy);

  return {
    sell,
    buy,
    value
  };
};

rejectZeroSize = obj => {
  return obj.size === "0.00000000";
};

const displayValue = (side, { value, volume, valuePerVolume }) => {
  console.log(
    `${side}: $${value}`,
    `@${volume} base,`,
    `$${valuePerVolume}/base`
  );
};

// const proposedBuy = ({ price, size }) => {

//   console.log

// };

const getFillForProductId = product_id =>
  hash({
    buys: getFills(product_id, "buy"),
    sells: getFills(product_id, "sell")
  })
    .then(keys)
    .then(flatten)
    .then(groupBy(prop("size")))
    .then(map(groupBy(prop("side"))))
    // .then(logAndReturn)
    .then(map(asdf))
    .then(keys)
    // .then(logAndReturn)
    .then(data => {
      return {
        value: flatten(pluck("value", data)),
        sell: flatten(pluck("sell", data)),
        buy: flatten(pluck("buy", data))
      };
    })
    .then(map(reject(propEq("size", "0.00000000"))))
    .then(({ value, sell, buy }) => {
      // console.log(buy);

      console.log(
        reverse(
          map(({ price, size }) => {
            return `${price} ${size}`;
          }, sortBy(z => parseFloat(prop("price", z)), buy))
        ).join("\n")
      );

      return { value, sell, buy };
    })
    .then(({ value, sell, buy }) => {
      const gains = sum(map(parseFloat, pluck("gains", value)));
      const volume = sum(map(parseFloat, pluck("size", value)));
      console.log(`$${gains}`, `@${volume} base,`, `$${gains / volume}/base`);
      return { value, sell, buy };
    })
    // .then( map( reject( )))
    .then(({ value, sell, buy }) => {
      // console.log("sell", sell.length);
      var sellValue = {
        value: sum(map(parseFloat, pluck("price", sell))),
        volume: sum(map(parseFloat, pluck("size", sell)))
      };

      sellValue.valuePerVolume = sellValue.value / sellValue.volume;
      // console.log(`$${gains}`, `@${volume} base,`, `$${gains / volume}/base`);
      return { value, sell: sellValue, buy };
    })
    .then(({ value, sell, buy }) => {
      // console.log("buy", buy.length);
      var buyValue = {
        value: sum(map(parseFloat, pluck("price", buy))),
        volume: sum(map(parseFloat, pluck("size", buy)))
      };

      buyValue.valuePerVolume = buyValue.value / buyValue.volume;
      return { value, sell, buy: buyValue };
    })
    .then(({ value, sell, buy }) => {
      displayValue("buy", buy);
      displayValue("sell", sell);

      return { sell, value, buy };
    })
    .then(({ value, sell, buy }) => {
      console.log(buy);

      return { value, sell, buy };
    });
// .then(mergeAll)
// .then(map(getValues))
// .then(map(sortBy(prop("created_at"))))
// .then(sides => {
//   let { buys, sells } = sides;

//   let values = [];

//   const matchSells = (buy, i) => {
//     viableSell = where({
//       size: equals(buy.size),
//       price: lte(buy.price)
//     });

//     const index = findIndex(viableSell, sells);

//     if (index > -1) {
//       const valuations = gains(buy, sells[index]);
//       // console.log(valuations);
//       buy.size = valuations.sell.size;
//       sells[index] = valuations.sell;
//       values.push(valuations.value);
//       return valuations.buy;
//     }

//     return buy;
//   };

//   buys = addIndex(map)(matchSells, buys);

//   return {
//     sells,
//     buys,
//     values
//   };
// })
// .then(map(getValues))
// .then(({ sells, buys, values }) => {
//   const dValue = buys.value - sells.value;
//   const dVolume = buys.volume - sells.volume;
//   const dValuePerVolume = dValue / dVolume;
//   console.log(`sell ${dVolume} @${dValuePerVolume}`);
//   return {
//     sells,
//     buys,
//     values
//   };
// })
// .then(logAndReturn)
// .catch(console.log);

keys(currencies).map(getFillForProductId);
