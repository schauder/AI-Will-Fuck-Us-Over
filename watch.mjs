// Rebuild the slides whenever a source file changes.
// Zero dependencies — uses Node's built-in fs.watch + child_process.
//
//   node watch.mjs      (or: make watch)
//
// Run this alongside `make serve` and just refresh the browser after a save.

import { watch } from "node:fs";
import { spawn } from "node:child_process";

const WATCHED = ["slides.adoc", "custom.css"];
let building = false;
let queued = false;
let timer = null;

function build() {
  if (building) {
    queued = true;
    return;
  }
  building = true;
  process.stdout.write("↻ building… ");
  const p = spawn("make", ["html"], { stdio: ["ignore", "ignore", "inherit"] });
  p.on("close", (code) => {
    building = false;
    console.log(code === 0 ? "done." : `FAILED (exit ${code}).`);
    if (queued) {
      queued = false;
      build();
    }
  });
}

function onChange() {
  clearTimeout(timer);
  timer = setTimeout(build, 150); // debounce editor save bursts
}

for (const file of WATCHED) {
  try {
    watch(file, onChange);
  } catch {
    console.warn(`(skipping watch on missing ${file})`);
  }
}

console.log(`Watching ${WATCHED.join(", ")} — Ctrl-C to stop.`);
build();
