const getFills = require("./getFills");

const defaults = {
  sort: {
    created_at: 1 // -1
  }
  // limit: 1000
};

const getBuyFills = currency => {
  return getFills(currency, "buy", defaults);
};

module.exports = getBuyFills;
