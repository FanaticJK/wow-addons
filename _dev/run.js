/*
 * Runtime smoke harness: loads the addon folders in this workspace into a Lua VM
 * (fengari) on top of the 3.3.5 API mock, then runs a scenario file against them.
 *
 *   node _dev/run.js <scenario.lua> [savedvariables-preload.lua]
 *
 * Exit code is non-zero if the scenario reported a failure or the mock collected
 * a runtime error, so this is usable as a regression gate.
 */
const fs = require('fs');
const path = require('path');
const { lua, lauxlib, lualib, to_luastring, to_jsstring } = require('fengari');

const DEV = __dirname;
const ROOT = path.resolve(DEV, '..');
const SEP = String.fromCharCode(92); // backslash, as .toc/.xml files spell paths

const scenario = process.argv[2] || path.join(DEV, 'smoke.lua');
const preload = process.argv[3] || null;

/* ---------- read the .toc / .xml load order ---------- */

const readBytes = p => {
  let b = fs.readFileSync(p);
  if (b[0] === 0xef && b[1] === 0xbb && b[2] === 0xbf) b = b.slice(3);
  return b;
};
const readText = p => readBytes(p).toString('latin1');

function resolveIn(dir, ref) {
  const parts = ref.split(SEP).join('/').split('/').filter(Boolean);
  let cur = dir;
  for (const part of parts) {
    if (!fs.existsSync(cur)) return null;
    const hit = fs.readdirSync(cur).find(e => e.toLowerCase() === part.toLowerCase());
    if (!hit) return null;
    cur = path.join(cur, hit);
  }
  return cur;
}

function collectXml(xmlPath, out, problems) {
  // strip comments first: bundled libs keep dead <Include>s commented out
  const src = readText(xmlPath).replace(/<!--[\s\S]*?-->/g, '');
  const dir = path.dirname(xmlPath);
  const re = /<(Script|Include)\s+file\s*=\s*"([^"]+)"/gi;
  let m;
  while ((m = re.exec(src))) {
    const target = resolveIn(dir, m[2]);
    if (!target) { problems.push(`${path.relative(ROOT, xmlPath)} -> missing "${m[2]}"`); continue; }
    if (target.toLowerCase().endsWith('.xml')) collectXml(target, out, problems);
    else out.push(target);
  }
}

function readAddon(dir) {
  const tocName = fs.readdirSync(dir).find(f => f.toLowerCase().endsWith('.toc'));
  if (!tocName) return null;
  const meta = {}, files = [], problems = [];
  for (const raw of readText(path.join(dir, tocName)).split(/\r?\n/)) {
    const line = raw.trim();
    if (!line) continue;
    if (line.startsWith('##')) {
      const m = line.match(/^##\s*([^:]+):\s*(.*)$/);
      if (m) meta[m[1].trim().toLowerCase()] = m[2].trim();
      continue;
    }
    if (line.startsWith('#')) continue;
    const target = resolveIn(dir, line);
    if (!target) { problems.push(`${tocName} -> missing "${line}"`); continue; }
    if (target.toLowerCase().endsWith('.xml')) collectXml(target, files, problems);
    else files.push(target);
  }
  return { name: path.basename(dir), dir, meta, files, problems };
}

const addons = fs.readdirSync(ROOT, { withFileTypes: true })
  .filter(d => d.isDirectory() && !d.name.startsWith('.') && d.name !== '_dev' && d.name !== 'node_modules')
  .map(d => readAddon(path.join(ROOT, d.name)))
  .filter(Boolean);

for (const a of addons) for (const p of a.problems) console.log('TOC/XML PROBLEM  ' + a.name + ': ' + p);

/* ---------- boot the Lua state ---------- */

const L = lauxlib.luaL_newstate();
lualib.luaL_openlibs(L);

function fail(what) {
  const msg = to_jsstring(lua.lua_tostring(L, -1));
  console.log('FATAL ' + what + ': ' + msg);
  process.exit(1);
}

function runFile(file) {
  if (lauxlib.luaL_loadbuffer(L, readBytes(file), null, to_luastring('@' + path.relative(ROOT, file))) !== lua.LUA_OK) fail('loading ' + file);
  if (lua.lua_pcall(L, 0, lua.LUA_MULTRET, 0) !== lua.LUA_OK) fail('running ' + file);
}

runFile(path.join(DEV, 'wowmock.lua'));
runFile(path.join(DEV, 'wowapi.lua'));

// SavedVariables preload: whatever the client would have restored from disk
if (preload) {
  console.log('preloading SavedVariables from ' + path.relative(ROOT, path.resolve(preload)));
  runFile(path.resolve(preload));
}

// compile every addon file up front and stash it in __CHUNKS[relativePath]
lua.lua_newtable(L);
lua.lua_setglobal(L, to_luastring('__CHUNKS'));
for (const a of addons) {
  for (const f of a.files) {
    const key = path.relative(ROOT, f).split(path.sep).join('/');
    lua.lua_getglobal(L, to_luastring('__CHUNKS'));
    if (lauxlib.luaL_loadbuffer(L, readBytes(f), null, to_luastring('@' + key)) !== lua.LUA_OK) fail('compiling ' + key);
    lua.lua_setfield(L, -2, to_luastring(key));
    lua.lua_pop(L, 1);
  }
}

// describe the addons to the Lua side
const manifest = addons.map(a => {
  const meta = Object.entries(a.meta).map(([k, v]) => `[${JSON.stringify(k)}]=${JSON.stringify(v)}`).join(',');
  const files = a.files.map(f => JSON.stringify(path.relative(ROOT, f).split(path.sep).join('/'))).join(',');
  return `MOCK.addons[${JSON.stringify(a.name)}] = {name=${JSON.stringify(a.name)}, metadata={${meta}}, files={${files}}}`;
}).join('\n');

const bootstrap = `
${manifest}
MOCK.loadOrder = {${addons.map(a => JSON.stringify(a.name)).join(',')}}

-- load one addon the way the client does: each file gets (addonName, addonPrivateTable)
function MOCK.loadAddon(name)
    local a = MOCK.addons[name]
    if not a then return false, 'no such addon: ' .. tostring(name) end
    if MOCK.loaded[name] then return true end
    MOCK.loaded[name] = true
    a.private = a.private or {}
    for _, file in ipairs(a.files) do
        local chunk = __CHUNKS[file]
        if not chunk then
            MOCK.errors[#MOCK.errors+1] = 'no compiled chunk for ' .. file
        else
            local ok, err = pcall(chunk, name, a.private)
            if not ok then
                MOCK.errors[#MOCK.errors+1] = file .. ': ' .. tostring(err)
            end
        end
    end
    MOCK.fire('ADDON_LOADED', name)
    return true
end

-- the SavedVariables each addon declares, so a scenario can inspect/dump them
function MOCK.savedVariables(name)
    local a = MOCK.addons[name]
    local out = {}
    if not a then return out end
    for _, key in ipairs({'savedvariables', 'savedvariablespercharacter'}) do
        local list = a.metadata[key]
        if list then
            for var in list:gmatch('[^,%s]+') do out[#out+1] = var end
        end
    end
    return out
end
`;

if (lauxlib.luaL_loadbuffer(L, to_luastring(bootstrap), null, to_luastring('@bootstrap')) !== lua.LUA_OK) fail('loading bootstrap');
if (lua.lua_pcall(L, 0, 0, 0) !== lua.LUA_OK) fail('running bootstrap');

/* ---------- run the scenario ---------- */

const scenarioPath = path.resolve(scenario);
if (lauxlib.luaL_loadbuffer(L, readBytes(scenarioPath), null, to_luastring('@' + path.basename(scenarioPath))) !== lua.LUA_OK) fail('loading scenario');
if (lua.lua_pcall(L, 0, 1, 0) !== lua.LUA_OK) {
  console.log('FATAL in scenario: ' + to_jsstring(lua.lua_tostring(L, -1)));
  process.exit(1);
}

// a scenario returns the number of failed checks
const failures = lua.lua_tointeger(L, -1) || 0;
console.log('\nscenario failures: ' + failures);
process.exitCode = failures ? 1 : 0;
