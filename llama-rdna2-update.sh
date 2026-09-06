#!/usr/bin/env bash
# ==============================================================================
# llama-rdna2.sh — run the RDNA2 (ROCm / gfx1030) llama.cpp server on the V620.
#
# This is the ROCm build (llama-cpp-rocm-0.0.0), NOT the Vulkan build. It runs
# the same Qwen3.8-27B model + params as models/models-preset.ini (131k ctx,
# q8_0 KV cache, native MTP spec decoding), but on the ROCm backend.
#
# WHY A CONTAINER: bare-metal ROCm 7.2.3 crashes at hsa_init() because it tries
# to allocate memory on the Polaris WX4100 (gfx803, unsupported). Restricting
# the container to /dev/kfd + /dev/dri/renderD128 (the V620 only) fixes it.
# Rootless podman fails this restriction (HSA_STATUS_ERROR_OUT_OF_RESOURCES),
# so this MUST run rootful:
#
#     sudo ~/Documents/llama-rdna2.sh
#
# NOTE: this container only ever exposes ONE GPU (V620, renderD128). Flags
# meant for a multi-GPU tensor-split rig (HIP_VISIBLE_DEVICES=0,1,
# --split-mode tensor --tensor-split 1,1, GGML_TP_SHARDED_OUTPUT) do not apply
# here and were deliberately left out — see the WHY A CONTAINER note above for
# why a second device node is never mapped in.
#
# TO SWITCH FROM THE VULKAN SERVER (same :8080 endpoint):
#   1. Stop the Vulkan router (takes down its worker too):
#        kill <router-pid>        # e.g. the `llama-server --models-preset ...` proc
#   2. Run this script:
#        sudo ~/Documents/llama-rdna2.sh
#   3. Verify:
#        docker logs -f llama-rdna2
#        curl -s http://127.0.0.1:8080/v1/models
#
# TO STOP:  docker rm -f llama-rdna2
# ==============================================================================
set -euo pipefail

# --- Config -------------------------------------------------------------------
LLAMA_BIN=/nix/store/3yxp35x24xkakranxcbxk7p0hd4an188-llama-cpp-rocm-0.0.0/bin/llama-server
MODEL_HOST=/home/ethan/Documents/models/Qwen3.8-27B-UD-Q6_K_XL.gguf
MODEL=/models/Qwen3.8-27B-UD-Q6_K_XL.gguf      # as seen inside the container
IMAGE=rocm/dev-ubuntu-22.04:7.2.3              # already pulled; base image is irrelevant (Nix binary is self-contained)
NAME=llama-rdna2
PORT=8080

# --- Sanity checks -----------------------------------------------------------
[[ -x "$LLAMA_BIN"  ]] || { echo "ERROR: RDNA2 binary not found: $LLAMA_BIN" >&2; exit 1; }
[[ -f "$MODEL_HOST" ]] || { echo "ERROR: model not found: $MODEL_HOST" >&2; exit 1; }
[[ "$(id -u)" == "0" ]] || { echo "ERROR: must run as root (rootful podman). Use: sudo $0" >&2; exit 1; }

# --- Clean up any previous instance ------------------------------------------
docker rm -f "$NAME" >/dev/null 2>&1 || true

# --- Launch -------------------------------------------------------------------
# Env:
#   HSA_OVERRIDE_GFX_VERSION=10.3.0  -> gates the fork's native gfx1030 kernel profile (required)
#   HSA_NO_SCRATCH_RECLAIM=1         -> stability, from the fork's tested launch env
#   GGML_HIP_SAFE_STATE_IO=1         -> stability, from the fork's tested launch env
#   GGML_HIP_RDNA2_AUTO=1            -> new: lets the fork auto-detect/tune the RDNA2 path
#                                        instead of relying solely on the GFX_VERSION override
#   SPEC_SIDECAR=1                   -> requested addition, untested on this build; harmless
#                                        no-op if llama-cpp-rocm-0.0.0 doesn't read it
docker run -d --name "$NAME" \
  --device=/dev/kfd --device=/dev/dri/renderD128 \
  -v /nix/store:/nix/store:ro \
  -v /home/ethan/Documents/models:/models:ro \
  -p "$PORT:$PORT" \
  -e HSA_OVERRIDE_GFX_VERSION=10.3.0 \
  -e HSA_NO_SCRATCH_RECLAIM=1 \
  -e GGML_HIP_SAFE_STATE_IO=1 \
  -e GGML_HIP_RDNA2_AUTO=1 \
  -e SPEC_SIDECAR=1 \
  "$IMAGE" \
  "$LLAMA_BIN" \
    -m "$MODEL" \
    --alias Qwen3.8-27B-Q6_K_XL \
    -ngl all --fit off --flash-attn on \
    --load-mode none \
    --ctx-size 131072 \
    --cache-type-k q8_0 --cache-type-v q8_0 --cache-ram 40960 \
    --batch-size 1024 --ubatch-size 512 \
    --parallel 1 --no-cont-batching \
    --threads 6 --threads-batch 8 \
    --spec-type draft-mtp --spec-draft-n-max 2 --spec-draft-p-min 0.0 \
    --temp 0.4 --top-p 0.90 --top-k 15 --min-p 0.02 --repeat-penalty 1.0 --presence-penalty 0.0 \
    --jinja --metrics \
    --host 0.0.0.0 --port "$PORT"

echo "Started '$NAME' on :$PORT (RDNA2/ROCm, 131k ctx, MTP)."
echo "  logs:   docker logs -f $NAME"
echo "  models: curl -s http://127.0.0.1:$PORT/v1/models"
echo "  stop:   docker rm -f $NAME"
