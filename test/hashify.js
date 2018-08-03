const should = require("should");

const hashify = require("../lib/hashify");

describe("hashify", () =>
  it("should show return hashify in base currency", () => {
    const input = {
      a: "a",
      b: 5
    };

    const output = {
      a: "a",
      b: 5,
      _hash: "a5d0190ec135fbae53fcc15b8eacb61b"
    };

    hashify(input).should.be.eql(output);
  }));
