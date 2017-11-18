module.exports = {
  /**
   * Application configuration section
   * http://pm2.keymetrics.io/docs/usage/application-declaration/
   */
  apps : [

    // First application
    {
      name: "Fills",
      script: "fills.coffee",
      interpreter: './node_modules/coffee-script/bin/coffee',
      watch: true
    },
    {
      name: "BTC-USD",
      script: "single.coffee",
      interpreter: './node_modules/coffee-script/bin/coffee',
      watch: true,
      env: {
        PRODUCT_ID: 'BTC-USD'
      }
    },
    {
      name: "ETH-USD",
      script: "single.coffee",
      interpreter: './node_modules/coffee-script/bin/coffee',
      watch: true,
      env: {
        PRODUCT_ID: 'ETH-USD'
      }
    },
    {
      name: "LTC-USD",
      script: "single.coffee",
      interpreter: './node_modules/coffee-script/bin/coffee',
      watch: true,
      env: {
        PRODUCT_ID: 'LTC-USD'
      }
    },
    {
      name: "ETH-BTC",
      script: "single.coffee",
      interpreter: './node_modules/coffee-script/bin/coffee',
      watch: true,
      env: {
        PRODUCT_ID: 'ETH-BTC'
      }
    },
    {
      name: "LTC-BTC",
      script: "single.coffee",
      interpreter: './node_modules/coffee-script/bin/coffee',
      watch: true,
      env: {
        PRODUCT_ID: 'LTC-BTC'
      }
    }
  ],

  deploy : {
  }
}
