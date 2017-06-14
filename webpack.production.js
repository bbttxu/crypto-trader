var path = require('path');

module.exports = {
  entry: './index.coffee',
  output: {
    filename: 'production.js',
    path: path.resolve(__dirname, 'dist')
  },
  module: {
    rules: [
      {
        test: /\.coffee$/,
        use: [ 'coffee-loader' ]
      }
    ]
  }
};
