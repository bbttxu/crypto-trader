const should = require("should");

const gains = require("../lib/gains");

describe("gains", () =>
  it("should show return gains in base currency", () => {
    const buy = {
      _id: "5b4ba26ce8d06e5c15a79dc8",
      created_at: "2018-01-16T14:40:58.017Z",
      trade_id: 3216555,
      product_id: "LTC-BTC",
      order_id: "ac4b9ca4-b0b3-4ddd-bc10-d56fe3b7dab4",
      user_id: "5581e98c626232006b0000fd",
      profile_id: "82895f2c-fa3e-4664-a338-eb4440aa3db8",
      liquidity: "M",
      price: "0.01705000",
      size: "0.10000000",
      fee: "0.0000000000000000",
      side: "buy",
      settled: true,
      usd_volume: "3.0467220000000000",
      title: "3216555 LTC-BTC"
    };
    const sell = {
      _id: "5b4ba290af85a05cc7b8549c",
      created_at: "2018-01-14T01:39:35.641Z",
      trade_id: 3170331,
      product_id: "LTC-BTC",
      order_id: "c52afa37-39f8-4164-be25-4e4ae4f3c26d",
      user_id: "5581e98c626232006b0000fd",
      profile_id: "82895f2c-fa3e-4664-a338-eb4440aa3db8",
      liquidity: "M",
      price: "0.01842000",
      size: "0.10000000",
      fee: "0.0000000000000000",
      side: "sell",
      settled: true,
      usd_volume: "3.8919720000000000",
      title: "3170331 LTC-BTC"
    };

    gains(buy, sell).should.be.eql({
      buy: {
        _id: "5b4ba26ce8d06e5c15a79dc8",
        created_at: "2018-01-16T14:40:58.017Z",
        trade_id: 3216555,
        product_id: "LTC-BTC",
        order_id: "ac4b9ca4-b0b3-4ddd-bc10-d56fe3b7dab4",
        user_id: "5581e98c626232006b0000fd",
        profile_id: "82895f2c-fa3e-4664-a338-eb4440aa3db8",
        liquidity: "M",
        price: "0.01705000",
        size: "0.00000000",
        fee: "0.0000000000000000",
        side: "buy",
        settled: true,
        usd_volume: "3.0467220000000000",
        title: "3216555 LTC-BTC"
      },
      sell: {
        _id: "5b4ba290af85a05cc7b8549c",
        created_at: "2018-01-14T01:39:35.641Z",
        trade_id: 3170331,
        product_id: "LTC-BTC",
        order_id: "c52afa37-39f8-4164-be25-4e4ae4f3c26d",
        user_id: "5581e98c626232006b0000fd",
        profile_id: "82895f2c-fa3e-4664-a338-eb4440aa3db8",
        liquidity: "M",
        price: "0.01842000",
        size: "0.00000000",
        fee: "0.0000000000000000",
        side: "sell",
        settled: true,
        usd_volume: "3.8919720000000000",
        title: "3170331 LTC-BTC"
      },
      value: {
        base: "0.00013700",
        size: "0.10000000",
        buy_order_id: "ac4b9ca4-b0b3-4ddd-bc10-d56fe3b7dab4",
        sell_order_id: "c52afa37-39f8-4164-be25-4e4ae4f3c26d"
      }
    });
  }));
