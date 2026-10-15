# 04 — Durable setup: forks + your own manifest

The patch overlay in [02-apply-patches.md](02-apply-patches.md) is great for archiving an
exact state, but re-applying patches by hand every sync is the thing that causes drift.
For ongoing product work, commit the delta into **your own forks** and describe the tree
with **your own manifest**. Then `repo sync` reproduces the patched tree with no manual
steps, and upstream Firefly updates become normal `git` rebases.

## Principle

- Keep `firefly-linux` as a **read-only upstream**, pinned to the release tag, for every
  repo you do **not** modify (most of `app/*`, `external/*`, prebuilts, docs…).
- **Fork only the repos you actually patch** (`buildroot`, `kernel`, `u-boot`, `rkbin`,
  `device/rockchip`) into your own git server, commit the mtv3 delta on branch
  `rv1126_rv1109/mtv3`, and override just those in the manifest.

## 1. Create forks and push the mtv3 branch

For each modified repo (already on branch `rv1126_rv1109/mtv3` from doc 02):

```bash
cd buildroot
git remote add eqvasset ssh://git@gitlab.com/eqvasset/buildroot.git
git push eqvasset rv1126_rv1109/mtv3
git push eqvasset rv1126_rv1109/firefly      # optional: pushes the baseline too
```

Repeat for `kernel`, `u-boot`, `rkbin`, `device/rockchip`.

## 2. Create a manifest repo

One small git repo, e.g. `gitlab.com/eqvasset/mtv3-bsp-manifest`:

```
mtv3-bsp-manifest/
├── default.xml
└── include/
    └── firefly_base.xml      # copy of rv1126_rv1109_ai/...v2.3.3b.xml, or <include> upstream
```

`default.xml`:

```xml
<manifest>
  <remote name="firefly-linux" fetch="https://gitlab.com/firefly-linux/"/>
  <remote name="eqvasset"      fetch="ssh://git@gitlab.com/eqvasset/"/>

  <!-- everything Firefly defines, pinned to the release -->
  <default remote="firefly-linux" sync-j="4"
           revision="refs/tags/rv1126_rv1109_ai/linux_release_v2.3.3b"/>
  <include name="include/firefly_base.xml"/>

  <!-- override ONLY the repos you forked; a 2nd <project> with the same name wins -->
  <project name="buildroot"       remote="eqvasset" revision="rv1126_rv1109/mtv3">
    <linkfile dest="Makefile"   src="build/Makefile"/>
    <linkfile dest="envsetup.sh" src="build/envsetup.sh"/>
  </project>
  <project name="kernel"          remote="eqvasset" revision="rv1126_rv1109/mtv3"/>
  <project name="u-boot"          remote="eqvasset" revision="rv1126_rv1109/mtv3"/>
  <project name="rkbin"           remote="eqvasset" revision="rv1126_rv1109/mtv3"/>
  <project name="device/rockchip" remote="eqvasset" revision="rv1126_rv1109/mtv3"/>

  <!-- your vision software (see 05) -->
  <project name="vision/mtv3-vision" remote="eqvasset" revision="main" path="app/vision"/>
</manifest>
```

## 3. Bootstrap from your manifest

```bash
repo init -u ssh://git@gitlab.com/eqvasset/mtv3-bsp-manifest -b main -m default.xml \
  --repo-url https://gitlab.com/firefly-linux/git-repo.git
repo sync -c -j8
./build.sh mtv3-rv1126.mk && ./build.sh allsave
```

No patches, no manual steps — the tree comes up already patched.

## Keeping up with upstream Firefly

When Firefly publishes a newer tag:

```bash
cd kernel
git fetch firefly-linux --tags
git checkout -B rv1126_rv1109/firefly <new-tag>
git checkout rv1126_rv1109/mtv3
git rebase rv1126_rv1109/firefly          # resolve conflicts once, in git
git push -f eqvasset rv1126_rv1109/mtv3
```

Then bump `revision` in `include/firefly_base.xml` to the new tag and `repo sync`.

## Which repos must be forked?

Exactly the ones with a non-empty patch in this bundle:
`buildroot`, `device/rockchip`, `kernel`, `u-boot`, `rkbin`. Everything else stays on
`firefly-linux`.
