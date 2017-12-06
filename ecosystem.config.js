
const {
  map,
  merge,
  concat
} = require( 'ramda' );

const defaults = {
  script: "single.coffee",
  interpreter: './node_modules/coffee-script/bin/coffee',
  watch: false,
  max_restarts: 10,
  max_memory_restart: '150M'
}

const setDefaults = ( app )=> {
  return merge( defaults, app )
}

const applyRandomReload = ( app )=> {
  return merge(
    app,
    {
      restart_delay: Math.round(
        (
          60 + (
            Math.random() * 60
          )
        )
      ) * 1000,
    }
  )
}

const setupProduct = ( product )=> {
  return {
    name: product,
    env: {
      PRODUCT_ID: product
    }
  }
}

module.exports = {
  /**
   * Application configuration section
   * http://pm2.keymetrics.io/docs/usage/application-declaration/
   */
  apps: concat(
    [
      // First application
      {
        name: "Fills",
        script: "fills.coffee",
        interpreter: './node_modules/coffee-script/bin/coffee',
        watch: true
      }
    ],
    map(
      setDefaults,
      map(
        applyRandomReload,
        map(
          setupProduct,
          [
            'BTC-USD',
            'ETH-USD',
            'LTC-USD',
            'ETH-BTC',
            'LTC-BTC'
          ]
        )
      )
    )
  ),
  deploy : {}
}
