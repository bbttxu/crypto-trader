const { omit } = require("ramda");

const md5 = require("blueimp-md5");

const hashify = data => {
  const hash = md5(JSON.stringify(omit(["_hash"], data)));

  data._hash = hash;

  return data;
};
module.exports = hashify;
