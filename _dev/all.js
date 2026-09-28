/*
 * One command that runs every check in this folder and prints a single summary.
 *
 *   node _dev/all.js
 *
 * Exits non-zero if anything failed, so it works as a pre-commit / regression gate.
 * Use -v to see the full output of each step instead of only the failures.
 */
const { spawnSync } = require('child_process');
const path = require('path');

const DEV = __dirname;
const verbose = process.argv.includes('-v') || process.argv.includes('--verbose');

const steps = [
  { name: 'static check (toc/xml/syntax/globals)', args: ['check.js'] },
  { name: 'runtime: smoke (fresh install, full UI)', args: ['run.js', 'smoke.lua'] },
  { name: 'runtime: migrate (legacy 2.6.0 + corrupt)', args: ['run.js', 'migrate.lua', 'sv_legacy.lua'] },
  { name: 'runtime: garbage (unreadable SavedVariables)', args: ['run.js', 'garbage.lua', 'sv_garbage.lua'] },
];

const results = [];
for (const step of steps) {
  const r = spawnSync(process.execPath, step.args.map(a => path.join(DEV, a)), {
    cwd: DEV, encoding: 'utf8',
  });
  const out = (r.stdout || '') + (r.stderr || '');
  const ok = r.status === 0;
  results.push({ step, ok, out });

  console.log((ok ? 'PASS  ' : 'FAIL  ') + step.name);
  if (verbose || !ok) {
    for (const line of out.split(/\r?\n/)) if (line.trim()) console.log('      ' + line);
  } else {
    // quiet mode: still surface the counts, they are the point of the run
    for (const line of out.split(/\r?\n/)) {
      if (/checks run|failures|lua files parsed|errors=|unknown/i.test(line)) console.log('      ' + line.trim());
    }
  }
}

const failed = results.filter(r => !r.ok);
console.log('');
console.log(failed.length === 0
  ? 'all ' + results.length + ' checks passed'
  : failed.length + ' of ' + results.length + ' checks FAILED: ' + failed.map(f => f.step.name).join(', '));
process.exitCode = failed.length ? 1 : 0;
