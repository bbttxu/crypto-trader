/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const SIZE_ZERO = "0.00000000";

const initialState = {
  fills: []
};

const md5 = require("blueimp-md5");

const { pluck } = require("sanctuary");

const {
  map,
  groupBy,
  prop,
  sum,
  pick,
  values,
  multiply,
  mapObjIndexed,
  negate,
  merge,
  add
} = require("ramda");

// const reconcile = require("../lib/reconciler");

const addValue = function(obj, side) {
  obj.value = multiply.apply(
    this,
    map(parseFloat, values(pick(["size", "price"], obj)))
  );
  return obj;
};

const minimums = {
  buy: {
    value: 0,
    size: 0
  },
  sell: {
    value: 0,
    size: 0
  }
};

const asdf = (foo, side) => {
  const size = sum(pluck("size", foo));
  let value = sum(pluck("value", foo));

  if (side === "buy") {
    value = negate(value);
  }

  return {
    size,
    value
  };
};

const sizeIsZero = ({ size }) => size === SIZE_ZERO;

const fillsReducer = (state, { type, fill }) => {
  if (typeof state === "undefined") {
    return initialState;
  }

  if (type === "FILLS_ADD") {
    state.fills.push(addValue(fill));

    const sideValues = merge(
      minimums,
      mapObjIndexed(asdf, groupBy(prop("side"), state.fills))
    );
    // console.log sideValues
    const onHand = (sideValues.buy.size || 0) - (sideValues.sell.size || 0);
    const deficit = Math.abs(add(sideValues.buy.value, sideValues.sell.value));

    console.log(deficit / onHand, onHand);
  }

  return state;
};

module.exports = fillsReducer;
