/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
require("dotenv").config({ silent: true });

const RESET_CALLS = 100;

let i = 1;

let persistedMongoConnection = undefined;

/*
.____    ._____.                      .__
|    |   |__\_ |______________ _______|__| ____   ______
|    |   |  || __ \_  __ \__  \\_  __ \  |/ __ \ /  ___/
|    |___|  || \_\ \  | \// __ \|  | \/  \  ___/ \___ \
|_______ \__||___  /__|  (____  /__|  |__|\___  >____  >
        \/       \/           \/              \/     \/
*/

const RSVP = require("rsvp");
const mongo = require("mongodb").MongoClient;

const { modulo, equals, __ } = require("ramda");

/*
___________                   __  .__
\_   _____/_ __  ____   _____/  |_|__| ____   ____   ______
 |    __)|  |  \/    \_/ ___\   __\  |/  _ \ /    \ /  ___/
 |     \ |  |  /   |  \  \___|  | |  (  <_> )   |  \\___ \
 \___  / |____/|___|  /\___  >__| |__|\____/|___|  /____  >
     \/             \/     \/                    \/     \/
*/

const shouldResetOnCounter = index => equals(0, modulo(index, RESET_CALLS));

//
//
const mongoConnection = (name = "default") =>
  new RSVP.Promise((resolve, reject) => {
    ++i;

    if (shouldResetOnCounter(i)) {
      console.log("RESET MONGODB CONNECTION", RESET_CALLS, i);
      if (persistedMongoConnection) {
        persistedMongoConnection.close();
      }
      persistedMongoConnection = undefined;
    }

    // return persisted connection if available
    if (persistedMongoConnection) {
      resolve(persistedMongoConnection);
    }

    // otherwise make connection
    return mongo.connect(
      process.env.MONGO_URL,
      // { useNewUrlParser: true },
      (err, connection) => {
        if (err) {
          reject(err);
        }

        // Persist connection
        persistedMongoConnection = connection;

        // resolve connection
        resolve(connection);
      }
    );
  });

/*
___________                             __
\_   _____/__  _________   ____________/  |_  ______
 |    __)_\  \/  /\____ \ /  _ \_  __ \   __\/  ___/
 |        \>    < |  |_> >  <_> )  | \/|  |  \___ \
/_______  /__/\_ \|   __/ \____/|__|   |__| /____  >
        \/      \/|__|                           \/
*/

module.exports = mongoConnection;
