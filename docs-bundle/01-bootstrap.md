# 01 — Bootstrap the Firefly baseline

Goal: a clean `repo` workspace synced to the exact Firefly release the mtv3 delta was made
against (`rv1126_rv1109_ai/linux_release_v2.3.3b`).

## Host prerequisites

Ubuntu 18.04/20.04 x86_64 is the tested host. Install the usual Rockchip/buildroot deps:

```bash
sudo apt update
sudo apt install -y git ssh make gcc libssl-dev liblz4-tool \
  expect g++ patchelf chrpath gawk texinfo diffstat binfmt-support \
  qemu-user-static live-build bison flex fakeroot cmake unzip device-tree-compiler \
  python3 python2 python3-pip ncurses-dev rsync curl bc
```

> The buildroot host-build fixes for **efl / expat / fakeroot** in this bundle exist because
> newer host toolchains break those packages. Apply them (next doc) before the first build.

## Get the `repo` tool (Firefly fork)

```bash
mkdir -p ~/bin
curl -s https://gitlab.com/firefly-linux/git-repo/-/raw/master/repo > ~/bin/repo
chmod a+x ~/bin/repo
export PATH=~/bin:$PATH        # add to ~/.bashrc to persist
```

## Init + sync the baseline

```bash
mkdir mtv3_bsp && cd mtv3_bsp

repo init \
  -u https://gitlab.com/firefly-linux/manifests.git \
  -b master \
  -m rv1126_rv1109_linux_ai_camera_release.xml \
  --repo-url https://gitlab.com/firefly-linux/git-repo.git

repo sync -c -j8
```

`repo sync` checks out every project at tag `rv1126_rv1109_ai/linux_release_v2.3.3b`
(exposed in each repo as the `m/*` remote-tracking ref).

## Verify you are on the right baseline

```bash
# top dir has no .git — this is expected
ls .repo/manifest.xml

# spot-check a repo is on the pinned tag
git -C buildroot for-each-ref --format='%(refname) %(objectname:short)' 'refs/remotes/m/*'
git -C buildroot describe --tags        # -> rv1126_rv1109_ai/linux_release_v2.3.3b
```

If those match, the baseline is correct. Continue to
[02-apply-patches.md](02-apply-patches.md).
