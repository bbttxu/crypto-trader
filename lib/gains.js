const SIZE_SIGNIFICANT_DIGITS = 8;

const sizeify = size => parseFloat(size).toFixed(SIZE_SIGNIFICANT_DIGITS);

const gains = (buy, sell) => {
  const minSize = Math.min(parseFloat(buy.size), parseFloat(sell.size));
  const value = {
    base: sizeify((parseFloat(sell.price) - parseFloat(buy.price)) * minSize),
    buy_order_id: buy.order_id,
    sell_order_id: sell.order_id,
    size: sizeify(minSize)
  };

  buy.size = sizeify(parseFloat(buy.size) - minSize);
  sell.size = sizeify(parseFloat(sell.size) - minSize);
  return {
    buy,
    sell,
    value
  };
};

module.exports = gains;
