/*
 * Regression test for check.js itself.
 *
 *   node _dev/checktest.js
 *
 * Builds a throwaway workspace with one addon and its own known-globals file, runs the
 * checker against it, and asserts on what it reports. Guards the file-scoped known.txt
 * entries: a reviewed leak in one file must not hide the same name in another file.
 */
const fs = require('fs');
const os = require('os');
const path = require('path');
const { spawnSync } = require('child_process');

let failures = 0, checks = 0;
const check = (cond, msg) => {
  checks++;
  console.log((cond ? '  ok    ' : '  FAIL  ') + msg);
  if (!cond) failures++;
};

const root = fs.mkdtempSync(path.join(os.tmpdir(), 'checktest-'));
try {
  const addon = path.join(root, 'Fixture');
  fs.mkdirSync(path.join(addon, 'libs'), { recursive: true });
  fs.writeFileSync(path.join(addon, 'Fixture.toc'), '## Interface: 30300\nlibs\\Lib.lua\nMain.lua\n');
  // the library reads a never-set `n`: reviewed, harmless, scoped to this file
  fs.writeFileSync(path.join(addon, 'libs', 'Lib.lua'), 'local x = n\nprint(x)\n');
  // the addon reads `n` too, and `scansize`: both must still be reported
  fs.writeFileSync(path.join(addon, 'Main.lua'), 'local y = n\nlocal s = "a" .. scansize\nprint(y, s)\n');
  const known = path.join(root, 'known.txt');
  fs.writeFileSync(known, [
    '# fixture',
    'print',
    'libs/Lib.lua: n',
    'libs/Gone.lua: z',   // stale: no such use
  ].join('\n'));

  const r = spawnSync(process.execPath, [path.join(__dirname, 'check.js'), root, '--known=' + known], { encoding: 'utf8' });
  const out = (r.stdout || '') + (r.stderr || '');
  const unknownLine = name => out.split(/\r?\n/).find(l => new RegExp('^\\s+' + name + '\\s+\\(').test(l)) || '';

  check(r.status !== 0, 'the checker fails the gate when something is undefined');
  check(/Fixture\/Main\.lua:1/.test(unknownLine('n')), '`n` is still reported in Main.lua');
  check(!/libs\/Lib\.lua/.test(unknownLine('n')), '`n` is accepted in the one file it is scoped to');
  check(/Fixture\/Main\.lua:2/.test(unknownLine('scansize')), 'an unlisted typo (`scansize`) is reported');
  check(/STALE known\.txt entry "libs\/Gone\.lua: z"/.test(out), 'a scoped entry that matches nothing is flagged as stale');
  check(!/print/.test(out.split('UNDEFINED')[1] || ''), 'a plain (global) entry is still accepted everywhere');
  if (failures) console.log(out);
} finally {
  fs.rmSync(root, { recursive: true, force: true });
}

console.log(`checks run: ${checks}  failures: ${failures}`);
process.exitCode = failures ? 1 : 0;
