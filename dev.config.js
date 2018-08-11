module.exports = {
  /**
   * Application configuration section
   * http://pm2.keymetrics.io/docs/usage/application-declaration/
   */
  apps: [
    // First application,
    {
      name: "stream",
      script: "stream.coffee",
      interpreter: "./node_modules/coffeescript/bin/coffee"
    },
    {
      name: "SINGLE",
      script: "single.js"
    },
    {
      name: "Fills2s",
      script: "fills2.js"
    }
    // {
    //   name: "MULTI",
    //   script: "multi.coffee",
    //   interpreter: './node_modules/coffeescript/bin/coffee',
    //   watch: true,
    //   env: {
    //     PRODUCT_ID: 'N/A'
    //   }
    // },
    // {
    //   name: "LTC-USD",
    //   script: "single.coffee",
    //   interpreter: './node_modules/coffeescript/bin/coffee',
    //   env: {
    //     PRODUCT_ID: 'LTC-USD'
    //   }
    // },

    // {
    //   name: "brain",
    //   script: "brain.coffee",
    //   interpreter: './node_modules/coffeescript/bin/coffee'
    // },
    // {
    //   name: "voice",
    //   script: "voice.coffee",
    //   interpreter: './node_modules/coffeescript/bin/coffee'
    // },
    // {
    //   name: "worker",
    //   script: "worker.coffee",
    //   interpreter: "./node_modules/coffeescript/bin/coffee"
    // }
    // {
    //   name: "kue",
    //   script: "kue.coffee",
    //   interpreter: "./node_modules/coffeescript/bin/coffee"
    // }
    // {
    //   name: "net",
    //   script: "net.coffee",
    //   interpreter: './node_modules/coffeescript/bin/coffee'
    // }
  ],
  deploy: {}
};
