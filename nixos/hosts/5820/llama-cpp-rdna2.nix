# RDNA2 (gfx1030) llama.cpp build for the single Radeon PRO V620.
#
# Builds the edwinbrowwn/llama.cpp-rdna2 fork (ROCm/HIP with gfx1030 kernel
# patches) via the flake's `packages.x86_64-linux.llama-rdna2` output and
# exposes it as `llama-server-rdna2`. The binary is renamed because
# ./llama-cpp-vulkan.nix already puts nixpkgs' Vulkan `llama-server` in the
# same system profile; two packages providing bin/llama-server would fail to
# install. The Vulkan setup is untouched.
#
# Note: this box also has an older Polaris (gfx803) card; ROCm 7 does not
# support it, so only the V620 (gfx1030) is a usable HIP device.
{ config, pkgs, inputs, ... }:

let
  llamaRdna2Pkg = inputs.self.packages.${pkgs.system}.llama-rdna2;

  llamaServerRdna2 = pkgs.runCommand "llama-server-rdna2" { } ''
    mkdir -p $out/bin
    ln -s ${llamaRdna2Pkg}/bin/llama-server $out/bin/llama-server-rdna2
  '';
in
{
  environment.systemPackages = [ llamaServerRdna2 ];

  # The fork gates its native gfx1030 kernel profile on this variable being
  # set before the process starts (see the repo README). It merges
  # harmlessly if the same variable is also set globally.
  environment.variables.HSA_OVERRIDE_GFX_VERSION = "10.3.0";

  # Recommended single-GPU launch (no tensor split / RCCL — this box runs
  # one usable GPU). Use a Q4–Q6 quant for ~27B-class models; Q8_0 (~29GB)
  # will not fit alongside a useful context on the ~30GB usable VRAM.
  #
  #   llama-server-rdna2 \
  #     -m /path/to/model.gguf \
  #     -ngl all \
  #     --flash-attn on \
  #     --ctx-size 32768 \
  #     --cache-type-k q8_0 --cache-type-v q8_0 \
  #     --batch-size 2048 --ubatch-size 256 \
  #     --parallel 1 \
  #     --jinja --metrics \
  #     --host 0.0.0.0 --port 8080
  #
  # Optional, from the fork's tested launch environment:
  #   HSA_NO_SCRATCH_RECLAIM=1 GGML_HIP_SAFE_STATE_IO=1
  #
  # Optional MTP/DFlash speculative decoding (only with a compatible draft
  # model):
  #   --spec-type draft-mtp --spec-draft-ngl all --spec-draft-n-max 3 \
  #   --spec-draft-type-k f16 --spec-draft-type-v f16 \
  #   --spec-draft-p-min 0.0 --spec-draft-p-split 0.10
  #
  # Optional stability settings for state-heavy workloads:
  #   --ctx-checkpoints 0 --cache-ram 0 --no-cache-idle-slots
}
