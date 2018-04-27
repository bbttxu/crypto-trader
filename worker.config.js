module.exports = {
  apps: [
    {
      name: "ml",
      script: "ml.coffee",
      interpreter: './node_modules/coffeescript/bin/coffee',
      instances : "max",
      exec_mode : "cluster"
    }
  ],
  deploy : {}
}
