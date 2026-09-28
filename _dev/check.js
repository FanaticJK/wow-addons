/*
 * Static checker for the WoW 3.3.5a addon folders in this workspace.
 *
 *   node _dev/check.js <workspace-root>
 *
 * What it does, per addon folder (a folder containing <Name>.toc):
 *   1. parses the .toc, verifies every listed file exists
 *   2. follows XML <Script>/<Include> lists, verifies every referenced file exists
 *   3. parses every Lua file (Lua 5.1 syntax, the client's dialect)
 *   4. reports globals that are read but never defined anywhere in the workspace
 *      and are not in known.txt (the WoW 3.3.5 API baseline)
 *   5. flags retail-only APIs that do not exist in 3.3.5
 *   6. flags string escapes like "\H" that Lua 5.1 silently turns into "H"
 *
 * Files are read as latin1 because the original addon files are not UTF-8.
 */
const fs = require('fs');
const path = require('path');
const luaparse = require('luaparse');

const ROOT = path.resolve(process.argv[2] || path.join(__dirname, '..'));
const KNOWN = new Set(
  fs.readFileSync(path.join(__dirname, 'known.txt'), 'utf8')
    .split(/\r?\n/).map(s => s.trim()).filter(s => s && !s.startsWith('#'))
);

// APIs that only exist in Retail / later Classic builds. Using them on 3.3.5 errors.
const RETAIL_ONLY = [
  'C_Container', 'C_Timer', 'C_Item', 'C_CVar', 'C_AddOns', 'C_GuildBank',
  'SetShown', 'SetColorTexture', 'BackdropTemplateMixin', 'GetItemInfoInstant',
  'ContainerFrame_GetContainerNumSlots', 'UnitGUID_', 'securecallfunction',
];

const errors = [], warnings = [];
const defined = new Set(), used = new Map();   // name -> [{file,line}]

const readText = f => fs.readFileSync(f, 'latin1').replace(/^﻿|^ï»¿/, '');
const rel = f => path.relative(ROOT, f).split(String.fromCharCode(92)).join('/');

function walkAddons() {
  return fs.readdirSync(ROOT, { withFileTypes: true })
    .filter(d => d.isDirectory() && !d.name.startsWith('.') && d.name !== '_dev' && d.name !== 'node_modules')
    .map(d => {
      const dir = path.join(ROOT, d.name);
      const toc = fs.readdirSync(dir).find(f => f.toLowerCase().endsWith('.toc'));
      return toc ? { name: d.name, dir, toc: path.join(dir, toc) } : null;
    })
    .filter(Boolean);
}

// resolve a path written with backslashes, case-insensitively
function resolveIn(dir, ref) {
  const parts = ref.split(String.fromCharCode(92)).join('/').split('/').filter(Boolean);
  let cur = dir;
  for (const part of parts) {
    if (!fs.existsSync(cur)) return null;
    const hit = fs.readdirSync(cur).find(e => e.toLowerCase() === part.toLowerCase());
    if (!hit) return null;
    cur = path.join(cur, hit);
  }
  return cur;
}

function collectXml(addon, xmlPath, out) {
  // comments matter: several bundled libs keep dead <Include>s commented out
  const src = readText(xmlPath).replace(/<!--[\s\S]*?-->/g, '');
  const dir = path.dirname(xmlPath);
  const re = /<(Script|Include)\s+file\s*=\s*"([^"]+)"/gi;
  let m;
  while ((m = re.exec(src))) {
    const target = resolveIn(dir, m[2]);
    if (!target) { errors.push(`${addon.name}: ${rel(xmlPath)} references missing file "${m[2]}"`); continue; }
    if (target.toLowerCase().endsWith('.xml')) collectXml(addon, target, out);
    else out.push(target);
  }
  collectXmlNames(src);
}

// A UI element with a name= attribute becomes a global of that name in the client, and children
// use "$parent" for the nearest named ancestor. check.js only reads Lua, so without this every
// XML-declared frame (and every "$parentTab2" child) shows up as an undefined global. Walk the
// tag stream, resolve "$parent" against a stack of ancestor names, and register the result.
function collectXmlNames(src) {
  const stack = [];   // resolved name (or null) per open element, innermost last
  const tag = /<(\/?)([A-Za-z][\w]*)([^>]*?)(\/?)>/g;
  let t;
  while ((t = tag.exec(src))) {
    const [, closing, , attrs, selfClose] = t;
    if (closing) { stack.pop(); continue; }
    let name = null;
    const na = /\bname\s*=\s*"([^"]+)"/i.exec(attrs);
    if (na) {
      const parent = [...stack].reverse().find(Boolean);
      name = parent ? na[1].replace(/\$parent/g, parent) : na[1].replace(/\$parent/g, '');
      if (/^[A-Za-z_][\w]*$/.test(name)) defined.add(name);
    }
    if (!selfClose) stack.push(name);
  }
}

function tocFiles(addon) {
  const out = [];
  // Target client is 3.3.5a: every addon must declare ## Interface: 30300 or it loads greyed-out
  // as out-of-date. Baggins shipped 30200 (3.2.0); this is how that surfaces.
  const iface = /##\s*Interface\s*:\s*(\d+)/i.exec(readText(addon.toc));
  if (!iface) errors.push(`${addon.name}: ${path.basename(addon.toc)} has no ## Interface line`);
  else if (iface[1] !== '30300') errors.push(`${addon.name}: ## Interface is ${iface[1]}, expected 30300`);
  for (const raw of readText(addon.toc).split(/\r?\n/)) {
    const line = raw.trim();
    if (!line || line.startsWith('#')) continue;
    const target = resolveIn(addon.dir, line);
    if (!target) { errors.push(`${addon.name}: ${path.basename(addon.toc)} lists missing file "${line}"`); continue; }
    if (target.toLowerCase().endsWith('.xml')) collectXml(addon, target, out);
    else out.push(target);
  }
  return out;
}

function scanLua(file) {
  let ast;
  // luaparse rejects `break;` ('end' expected near ';') even though Lua 5.1's grammar allows an
  // optional ';' after any laststat -- the real 3.3.5 client accepts it. Drop the semicolon for
  // the parse only, swapping it for a space so line/column offsets in error messages stay exact.
  const src = readText(file).replace(/\bbreak([ \t]*);/g, 'break$1 ');
  try {
    ast = luaparse.parse(src, {
      luaVersion: '5.1', locations: true, scope: true, comments: false,
      encodingMode: 'pseudo-latin1',
    });
  } catch (e) {
    errors.push(`SYNTAX ${rel(file)}:${e.line || '?'}: ${e.message}`);
    return;
  }
  const note = (n, name) => {
    if (!used.has(name)) used.set(name, []);
    used.get(name).push({ file, line: n.loc.start.line });
  };
  (function walk(node, assignTarget) {
    if (!node || typeof node !== 'object') return;
    if (Array.isArray(node)) return node.forEach(n => walk(n));
    if (node.type === 'AssignmentStatement') {
      node.variables.forEach(v => {
        if (v.type === 'Identifier' && v.isLocal === false) defined.add(v.name);
        else walk(v);
      });
      walk(node.init);
      return;
    }
    if (node.type === 'FunctionDeclaration' && node.identifier &&
        node.identifier.type === 'Identifier' && node.identifier.isLocal === false) {
      defined.add(node.identifier.name);
    }
    if (node.type === 'Identifier' && node.isLocal === false) note(node, node.name);
    // CreateFrame(type, "Name", ...) publishes "Name" as a global, same as an XML name= attribute.
    if (node.type === 'CallExpression' && node.base && node.base.type === 'Identifier' &&
        node.base.name === 'CreateFrame' && node.arguments[1] &&
        node.arguments[1].type === 'StringLiteral') {
      const nm = (node.arguments[1].raw || '').replace(/^["']|["']$/g, '');
      if (/^[A-Za-z_][\w]*$/.test(nm)) defined.add(nm);
    }
    // Lua 5.1 accepts an unknown escape and drops the backslash, so a texture path written
    // "Interface\Buttons\..." silently becomes "InterfaceButtons..." (Carbonite shipped two)
    if (node.type === 'StringLiteral' && /^["']/.test(node.raw || '')) {
      // consume escapes pairwise, so the second half of a valid "\\" is never looked at alone
      const bad = (node.raw.match(/\\[\s\S]/g) || []).find(e => !/[abfnrtv\\"'\r\n0-9]/.test(e[1]));
      if (bad) errors.push(`ESCAPE ${rel(file)}:${node.loc.start.line}: "${bad}" is not an escape, Lua 5.1 reads it as "${bad[1]}"`);
    }
    for (const k of Object.keys(node)) {
      // 'globals' is luaparse's own list of the same identifiers; walking it counts every use twice
      if (k === 'loc' || k === 'range' || k === 'globals') continue;
      walk(node[k]);
    }
  })(ast);
}

const addons = walkAddons();
const luaFiles = [];
for (const a of addons) for (const f of tocFiles(a)) if (f.toLowerCase().endsWith('.lua')) luaFiles.push(f);
luaFiles.forEach(scanLua);

// undefined globals
const unknown = [];
for (const [name, sites] of used) {
  if (defined.has(name) || KNOWN.has(name)) continue;
  unknown.push({ name, sites });
}
unknown.sort((a, b) => b.sites.length - a.sites.length);

// retail-only APIs
for (const api of RETAIL_ONLY) {
  const sites = used.get(api);
  if (sites) warnings.push(`RETAIL-ONLY "${api}" used at ` + sites.map(s => `${rel(s.file)}:${s.line}`).join(', '));
}

console.log(`addons: ${addons.map(a => a.name).join(', ')}`);
console.log(`lua files parsed: ${luaFiles.length}`);
if (errors.length) { console.log('\n== ERRORS =='); errors.forEach(e => console.log('  ' + e)); }
if (warnings.length) { console.log('\n== WARNINGS =='); warnings.forEach(w => console.log('  ' + w)); }
if (unknown.length) {
  console.log('\n== UNDEFINED GLOBALS (not in known.txt) ==');
  for (const u of unknown) {
    console.log(`  ${u.name}  (${u.sites.length}x)  ${u.sites.slice(0, 3).map(s => rel(s.file) + ':' + s.line).join(' ')}`);
  }
}
console.log(`\nerrors=${errors.length} warnings=${warnings.length} unknown-globals=${unknown.length}`);

// All three fail the gate. An undefined global is how the `cVersion` typo in Bagnon_Forever
// silently wiped the offline cache on every login, and a retail-only API is a runtime error on
// 3.3.5 -- neither is a thing to merely mention. A genuinely new 3.3.5 global or dependency
// belongs in known.txt, added deliberately after reading the report.
process.exitCode = (errors.length || warnings.length || unknown.length) ? 1 : 0;
