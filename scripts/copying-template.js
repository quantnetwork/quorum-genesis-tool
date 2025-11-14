// CommonJS version (works on Node 18)
const fs = require("node:fs");
const fsp = require("node:fs/promises");
const path = require("node:path");

const SRC  = path.join(__dirname, "..", "src", "templates");
const DEST = path.join(__dirname, "..", "build", "templates");

(async () => {
  try {
    if (!fs.existsSync(SRC)) {
      console.error(`Missing ${SRC}`);
      process.exit(1);
    }
    await fsp.mkdir(path.join(__dirname, "..", "build"), { recursive: true });
    // Node 18+: fsp.cp is available
    await fsp.cp(SRC, DEST, { recursive: true });
    console.log(`Copied ${SRC} -> ${DEST}`);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
})();
