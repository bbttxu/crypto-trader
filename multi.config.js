module.exports = {
  apps: [
    {
      name: "MULTI",
      script: "multi.coffee",
      interpreter: './node_modules/coffeescript/bin/coffee',
    },
    {
      name: "stream",
      script: "stream.coffee",
      interpreter: './node_modules/coffeescript/bin/coffee'
    },
    {
      name: "worker",
      script: "worker.coffee",
      interpreter: './node_modules/coffeescript/bin/coffee'
    },
    {
      name: "kue",
      script: "kue.coffee",
      interpreter: './node_modules/coffeescript/bin/coffee'
    },
    {
      name: "ml",
      script: "ml.coffee",
      interpreter: './node_modules/coffeescript/bin/coffee'
    }

  ],
  deploy : {}
}
