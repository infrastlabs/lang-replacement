const webpackMerge = require('webpack-merge');
const commonConfig = require('./webpack.common.js');

module.exports = webpackMerge(commonConfig, {
  mode: 'production',
  // devtool: 'source-map',
  module: {
    rules: [
      /* {
        test: /\.(woff|woff2|eot|ttf|ico)$/,
        use: [
          {
            loader: 'url-loader',
            options: { limit: 25000 },
          },
        ],
      },
      {
        test: /\.(gif|png|jpe?g|svg)$/i,
        use: [
          'file-loader',
          {
            loader: 'image-webpack-loader',
            options: {},
          },
        ],
      }, */
      {
        test: /\.(woff|woff2|eot|ttf|svg|ico|png|jpg|gif)$/,
        use: [
          {
            loader: 'file-loader',
            // options: { limit: 25000 }
          },
        ],
      },
    ],
  },
});
