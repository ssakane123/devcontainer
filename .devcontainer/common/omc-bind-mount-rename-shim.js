// Preloaded via NODE_OPTIONS=--require=... from post-create.sh (design.md §2.23).
// Wraps fs.rename* so that when omc setup's atomic-rename hits an unrecoverable
// kernel error against a per-file bind mount, we fall back to an in-place write
// (open+truncate+write, which the kernel allows on bind-mounted files). Scope
// is restricted to an allowlist so unrelated failures are not silently masked.
//
// The kernel returns different errno depending on how the tmp file's fs relates
// to the bind-mount target's fs:
//   - EBUSY: tmp and target on same fs; rename target is a mount point
//   - EXDEV: tmp on volume (ext4) and target on host (virtiofs) — same problem,
//            different diagnosis. Observed on Docker Desktop on macOS via
//            virtiofs bind mounts.
// Both are safe to fall back on because the target IS writable in-place.
'use strict';
const fs = require('fs');

const BIND_MOUNT_TARGETS = new Set([
  '/home/vscode/.claude/CLAUDE.md',
]);

const RECOVERABLE_CODES = new Set(['EBUSY', 'EXDEV']);

const isBindMountRenameFailure = (err, dst) =>
  err && RECOVERABLE_CODES.has(err.code) && BIND_MOUNT_TARGETS.has(dst);

const inPlaceReplace = (src, dst) => {
  const content = fs.readFileSync(src);
  fs.writeFileSync(dst, content);
  try { fs.unlinkSync(src); } catch { /* best-effort tmp cleanup */ }
};

const origRenameSync = fs.renameSync;
fs.renameSync = function (src, dst) {
  try {
    return origRenameSync.call(fs, src, dst);
  } catch (err) {
    if (isBindMountRenameFailure(err, dst)) {
      inPlaceReplace(src, dst);
      return;
    }
    throw err;
  }
};

const origRename = fs.rename;
fs.rename = function (src, dst, cb) {
  origRename.call(fs, src, dst, (err) => {
    if (isBindMountRenameFailure(err, dst)) {
      try {
        inPlaceReplace(src, dst);
        cb(null);
      } catch (e) {
        cb(e);
      }
      return;
    }
    cb(err);
  });
};

if (fs.promises && fs.promises.rename) {
  const origPromiseRename = fs.promises.rename;
  fs.promises.rename = async function (src, dst) {
    try {
      return await origPromiseRename.call(fs.promises, src, dst);
    } catch (err) {
      if (isBindMountRenameFailure(err, dst)) {
        inPlaceReplace(src, dst);
        return;
      }
      throw err;
    }
  };
}
