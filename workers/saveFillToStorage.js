/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const JOB = "SAVE_FILL_TO_STORAGE";
const COLLECTION = "fills";

let counter = 0;

/*
.____    ._____.                      .__
|    |   |__\_ |______________ _______|__| ____   ______
|    |   |  || __ \_  __ \__  \\_  __ \  |/ __ \ /  ___/
|    |___|  || \_\ \  | \// __ \|  | \/  \  ___/ \___ \
|_______ \__||___  /__|  (____  /__|  |__|\___  >____  >
        \/       \/           \/              \/     \/
*/

const kue = require("kue");

const mongoDb = require("../lib/mongoDb");

const queue = kue.createQueue();

const { pick } = require("ramda");
/*
___________                   __  .__
\_   _____/_ __  ____   _____/  |_|__| ____   ____   ______
 |    __)|  |  \/    \_/ ___\   __\  |/  _ \ /    \ /  ___/
 |     \ |  |  /   |  \  \___|  | |  (  <_> )   |  \\___ \
 \___  / |____/|___|  /\___  >__| |__|\____/|___|  /____  >
     \/             \/     \/                    \/     \/
*/

const addFillToQueue = fill => {
  const title = `${fill.trade_id} ${fill.product_id}`;
  fill.title = title;
  console.log(fill);
  queue
    .create(JOB, fill)
    .attempts(5)
    .backoff({ type: "exponential" })
    .removeOnComplete(true)
    .save();
  return fill;
};

const onErr = error => {
  console.log("we got a muthafuckin err");
  console.log(error);
  return error;
};

const minimumProperties = ["trade_id", "product_id", "order_id"];

const saveFillToStorage = ({ data }, callback) => {
  // console.log("do", data);
  mongoDb(COLLECTION).then(db => {
    // console.log("about to insert", pick(minimumProperties, data));
    db.findOne(pick(minimumProperties, data), (err, results) => {
      if (err) {
        onErr(err);
      }
      if (results === null) {
        // console.log("know now to insert", pick(minimumProperties, data));
        // console.log results, fill.data
        // console.log pick minimumProperties, fill.data

        db.insert(data, (err, { ops }) => {
          if (err) {
            onErr(err);
          }

          console.log(
            JOB,
            "saved",
            ops[0].product_id,
            ops[0].trade_id,
            ++counter
          );
          setTimeout(callback, 100);
        });
      }

      if (results !== null) {
        // console.log("already saved!", pick(minimumProperties, data));
        callback();
      }
    });
  });
};

const process = () => queue.process(JOB, saveFillToStorage);

queue.on("error", error => console.log(JOB, "ERROR", error));

/*
.____           __               .___         __  .__    .__
|    |    _____/  |_  ______   __| _/____   _/  |_|  |__ |__| ______
|    |  _/ __ \   __\/  ___/  / __ |/  _ \  \   __\  |  \|  |/  ___/
|    |__\  ___/|  |  \___ \  / /_/ (  <_> )  |  | |   Y  \  |\___ \
|_______ \___  >__| /____  > \____ |\____/   |__| |___|  /__/____  >
        \/   \/          \/       \/                   \/        \/     \/
*/

module.exports = {
  addFillToQueue,
  process
};
