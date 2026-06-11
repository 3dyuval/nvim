// Generates mdn-data.json in the VSCode custom-data schema
// (vscode-html-languageservice), usable both by the hover.nvim MDN provider and
// as a `customData` source for html-ls / vue_ls.
//
// Regenerate (bun, with sandbox-writable tmp):
//   BUN_TMPDIR="$TMPDIR" BUN_INSTALL="$TMPDIR/.bun" \
//     bun add @vscode/web-custom-data @mdn/browser-compat-data
//   bun gen.mjs
//
// Sources:
//   @vscode/web-custom-data  -> HTML tags + global attributes (prose + MDN refs)
//   @mdn/browser-compat-data -> canonical MDN urls for JS globals (no prose)
import bcd from "@mdn/browser-compat-data" with { type: "json" };
import html from "@vscode/web-custom-data/data/browsers.html-data.json" with { type: "json" };

// Upstream html tags/globalAttributes are already in the custom-data schema and
// already carry `references` with MDN urls. Pass them through, trimming the
// per-browser `browsers`/`status` noise the language server doesn't need here.
const slim = (entry) => {
  const out = { name: entry.name };
  if (entry.description) out.description = entry.description; // {kind, value}
  if (entry.attributes) out.attributes = entry.attributes;
  if (entry.references) out.references = entry.references;
  if (entry.valueSet) out.valueSet = entry.valueSet;
  return out;
};

const tags = html.tags.map(slim);
const globalAttributes = html.globalAttributes.map(slim);
const valueSets = html.valueSets ?? [];

// JS globals: no offline prose, but emit name + canonical MDN url so the hover
// provider can link out. Non-standard key (ignored by language servers).
const jsGlobals = [];
for (const [k, v] of Object.entries(bcd.javascript.builtins)) {
  if (k === "__compat") continue;
  const url = v.__compat && v.__compat.mdn_url;
  if (url) jsGlobals.push({ name: k, references: [{ name: "MDN Reference", url }] });
}

const data = {
  version: 1.1,
  // marker so consumers know where this came from / that it's generated
  _generatedBy: "hover-mdn/gen.mjs (@vscode/web-custom-data + @mdn/browser-compat-data)",
  tags,
  globalAttributes,
  valueSets,
  jsGlobals,
};

await Bun.write("mdn-data.json", JSON.stringify(data, null, 2) + "\n");
console.log("tags:", tags.length, "globalAttributes:", globalAttributes.length, "jsGlobals:", jsGlobals.length);
