var path = require('path');
var nodeExternals = require( 'webpack-node-externals' );

module.exports = {
  entry: './index.coffee',
  target: 'node',
  externals: [nodeExternals()],
  output: {
    filename: 'production.js',
    path: path.resolve(__dirname, 'dist'),
    libraryTarget: 'commonjs2'
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
