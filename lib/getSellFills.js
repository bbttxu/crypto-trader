const getFills = require("./getFills");

const defaults = {
  sort: {
    created_at: -1 // 1
  }
  // limit: 1000
};

const getSellFills = currency => {
  return getFills(currency, "sell", defaults);
};

module.exports = getSellFills;
