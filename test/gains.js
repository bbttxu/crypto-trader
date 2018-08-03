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
        gains: "0.00013700",
        size: "0.10000000",
        buy_order_id: "ac4b9ca4-b0b3-4ddd-bc10-d56fe3b7dab4",
        sell_order_id: "c52afa37-39f8-4164-be25-4e4ae4f3c26d"
      }
    });

    it("should show return gains in base currency", () => {
      const buy = {
        _id: "5b4d259d30aa5d867f2a47cd",
        created_at: "2018-01-06T02:13:05.395Z",
        trade_id: 24535070,
        product_id: "ETH-USD",
        order_id: "88639474-0fe6-4274-9fec-3cd1feb5cfcc",
        user_id: "5581e98c626232006b0000fd",
        profile_id: "82895f2c-fa3e-4664-a338-eb4440aa3db8",
        liquidity: "T",
        price: "965.01000000",
        size: "0.01000000",
        fee: "0.0289503000000000",
        side: "buy",
        settled: true,
        usd_volume: "9.6501000000000000",
        title: "24535070 ETH-USD"
      };
      const sell = {
        _id: "5b4d25c030aa5d867f2a4900",
        created_at: "2018-01-01T08:27:46.496Z",
        trade_id: 23861864,
        product_id: "ETH-USD",
        order_id: "a17cd3e4-5020-4d1f-bee6-6692cd8b268c",
        user_id: "5581e98c626232006b0000fd",
        profile_id: "82895f2c-fa3e-4664-a338-eb4440aa3db8",
        liquidity: "T",
        price: "743.41000000",
        size: "0.01000000",
        fee: "0.0223023000000000",
        side: "sell",
        settled: true,
        usd_volume: "7.4341000000000000",
        title: "23861864 ETH-USD"
      };

      gains(buy, sell).should.be.eql({
        buy: {
          _id: "5b4d259d30aa5d867f2a47cd",
          created_at: "2018-01-06T02:13:05.395Z",
          trade_id: 24535070,
          product_id: "ETH-USD",
          order_id: "88639474-0fe6-4274-9fec-3cd1feb5cfcc",
          user_id: "5581e98c626232006b0000fd",
          profile_id: "82895f2c-fa3e-4664-a338-eb4440aa3db8",
          liquidity: "T",
          price: "965.01000000",
          size: "0.01000000",
          fee: "0.0289503000000000",
          side: "buy",
          settled: true,
          usd_volume: "9.6501000000000000",
          title: "24535070 ETH-USD"
        },
        sell: {
          _id: "5b4d25c030aa5d867f2a4900",
          created_at: "2018-01-01T08:27:46.496Z",
          trade_id: 23861864,
          product_id: "ETH-USD",
          order_id: "a17cd3e4-5020-4d1f-bee6-6692cd8b268c",
          user_id: "5581e98c626232006b0000fd",
          profile_id: "82895f2c-fa3e-4664-a338-eb4440aa3db8",
          liquidity: "T",
          price: "743.41000000",
          size: "0.01000000",
          fee: "0.0223023000000000",
          side: "sell",
          settled: true,
          usd_volume: "7.4341000000000000",
          title: "23861864 ETH-USD"
        },
        value: {
          gains: "0.00013700",
          size: "0.10000000",
          buy_order_id: "ac4b9ca4-b0b3-4ddd-bc10-d56fe3b7dab4",
          sell_order_id: "c52afa37-39f8-4164-be25-4e4ae4f3c26d"
        }
      });
    });
  }));
