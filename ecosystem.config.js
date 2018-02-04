
const {
  map,
  merge,
  mergeDeepLeft,
  concat,
  addIndex
} = require( 'ramda' );

const defaults = {
  script: "single.coffee",
  interpreter: './node_modules/coffeescript/bin/coffee',
  watch: false,
  max_restarts: 10,
  max_memory_restart: '1000M'
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
          90 + (
            Math.random() * 90
          )
        )
      ) * 1000,
    }
  )
}

const applyHourlyCron = ( app, index )=> {
  return merge(
    app,
    {
      cron_restart: ( 59 - index ) + " * * * *"
    }
  )
}

const applyDelayedStart = ( app, index )=> {
  return mergeDeepLeft(
    app,
    {
      env: {
        DELAY: ( index * 6 )
      }
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
  apps: addIndex( map )(
    applyHourlyCron,
      addIndex( map )(
        applyDelayedStart,
        map(
          applyRandomReload,
          concat(
            [
              // Brain
              {
                name: "Brain",
                script: "brain.coffee",
                interpreter: './node_modules/coffeescript/bin/coffee'
              },
              // First application
              {
                name: "Worker",
                script: "worker.coffee",
                interpreter: './node_modules/coffeescript/bin/coffee'
              },
              // First application
              {
                name: "Fills",
                script: "fills.coffee",
                interpreter: './node_modules/coffeescript/bin/coffee'
              },
              // First application
              {
                name: "stream",
                script: "stream.coffee",
                interpreter: './node_modules/coffeescript/bin/coffee'
              }
            ],
            map(
              setDefaults,
              map(
                setupProduct,
                [
                  'BCH-USD',
                  'ETH-USD',
                  'LTC-USD',
                  'BCH-BTC',
                  'ETH-BTC',
                  'LTC-BTC'
                ]
              )
            )
          )
        )
      )
    )
  ,
  deploy : {}
}
