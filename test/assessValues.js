const should = require("should");

assessValue = require("../lib/assessValues.js");

describe("assessValue of payload", () => {
  it("basic", () => {
    const input = [
      {
        created_at: "2018-06-10T21:22:31.418Z",
        trade_id: 35729580,
        product_id: "ETH-USD",
        liquidity: "M",
        price: "520.00000000",
        size: "0.00000000",
        fee: "0.0000000000000000",
        side: "buy",
        settled: true,
        usd_volume: "520.0000000000000000",
        title: "35729580 ETH-USD"
      },
      {
        created_at: "2018-06-12T16:49:27.299Z",
        trade_id: 35831799,
        product_id: "ETH-USD",
        liquidity: "M",
        price: "520.00000000",
        size: "1.00000000",
        fee: "0.0000000000000000",
        side: "buy",
        settled: true,
        usd_volume: "520.0000000000000000",
        title: "35831799 ETH-USD"
      },
      {
        created_at: "2018-06-12T19:07:26.378Z",
        trade_id: 35840495,
        product_id: "ETH-USD",
        liquidity: "M",
        price: "500.00000000",
        size: "0.00000000",
        fee: "0.0000000000000000",
        side: "buy",
        settled: true,
        usd_volume: "1000.0000000000000000",
        title: "35840495 ETH-USD"
      },
      {
        created_at: "2018-06-13T09:21:56.775Z",
        trade_id: 35879645,
        product_id: "ETH-USD",
        liquidity: "M",
        price: "475.00000000",
        size: "0.00000000",
        fee: "0.0000000000000000",
        side: "buy",
        settled: true,
        usd_volume: "950.0000000000000000",
        title: "35879645 ETH-USD"
      },
      {
        created_at: "2018-06-22T13:05:44.455Z",
        trade_id: 36349215,
        product_id: "ETH-USD",
        liquidity: "M",
        price: "475.00000000",
        size: "0.00000000",
        fee: "0.0000000000000000",
        side: "buy",
        settled: true,
        usd_volume: "950.0000000000000000",
        title: "36349215 ETH-USD"
      },
      {
        created_at: "2018-06-24T06:10:29.607Z",
        trade_id: 36446059,
        product_id: "ETH-USD",
        liquidity: "M",
        price: "445.00000000",
        size: "0.00000000",
        fee: "0.0000000000000000",
        side: "buy",
        settled: true,
        usd_volume: "890.0000000000000000",
        title: "36446059 ETH-USD"
      },
      {
        created_at: "2018-06-24T15:46:48.894Z",
        trade_id: 36468852,
        product_id: "ETH-USD",
        liquidity: "M",
        price: "425.00000000",
        size: "0.00000000",
        fee: "0.0000000000000000",
        side: "buy",
        settled: true,
        usd_volume: "1275.0000000000000000",
        title: "36468852 ETH-USD"
      },
      {
        created_at: "2018-07-10T11:32:39.896Z",
        trade_id: 37139139,
        product_id: "ETH-USD",
        liquidity: "M",
        price: "445.00000000",
        size: "0.00000000",
        fee: "0.0000000000000000",
        side: "buy",
        settled: true,
        usd_volume: "890.0000000000000000",
        title: "37139139 ETH-USD"
      },
      {
        created_at: "2018-07-12T21:39:06.502Z",
        trade_id: 37250309,
        product_id: "ETH-USD",
        liquidity: "M",
        price: "425.00000000",
        size: "0.26598527",
        fee: "0.0000000000000000",
        side: "buy",
        settled: true,
        usd_volume: "113.0437397500000000",
        title: "37250309 ETH-USD"
      },
      {
        created_at: "2018-07-12T21:39:06.502Z",
        trade_id: 37250308,
        product_id: "ETH-USD",
        liquidity: "M",
        price: "425.00000000",
        size: "2.73401473",
        fee: "0.0000000000000000",
        side: "buy",
        settled: true,
        usd_volume: "1161.9562602500000000",
        title: "37250308 ETH-USD"
      }
    ];

    const output = { value: 1795, volume: 4, valuePerVolume: 448.75 };

    assessValue(input).should.be.eql(output);
  });
});
