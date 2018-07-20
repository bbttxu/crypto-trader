const { map, sum, pluck } = require("ramda");

const getValue = ({ price, size }) => {
  return {
    value: parseFloat(size) * parseFloat(price),
    size,
    price
  };
};

const assessValues = data => {
  const values = map(getValue, data);
  const value = sum(map(parseFloat, pluck("value", values)));
  const volume = sum(map(parseFloat, pluck("size", values)));

  return {
    value,
    volume,
    valuePerVolume: value / volume
  };
};

module.exports = assessValues;
