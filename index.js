#!/usr/bin/env node
(async () => {
  try {
    const { main } = require('./build'); // ensure build exports main
    await Promise.resolve(main());
  } catch (err) {
    const showStack = process.argv.includes('--stackTraceOnError');
    if (showStack && err && err.stack) {
      console.error(`Fatal error: ${err.stack}`);
    } else if (err && err.message) {
      console.error(`Fatal error: ${err.message}`);
    } else {
      console.error(`Fatal error: ${err}`);
    }
    process.exit(1);
  }
})();

// Extra safety: catch unhandled promise rejections that occur outside the try/catch
process.on('unhandledRejection', (err) => {
  const showStack = process.argv.includes('--stackTraceOnError');
  const msg = err && (showStack && err.stack ? err.stack : err.message || String(err));
  console.error(`Fatal error (unhandledRejection): ${msg}`);
  process.exit(1);
});