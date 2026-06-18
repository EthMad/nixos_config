{ config, pkgs, inputs, ... }:

   # llama.cpp ROCm build with web UI support
   # UI assets fetched from HF bucket — re-prefetch when upstream updates the UI
   {
     environment.systemPackages = with pkgs; [
       (inputs.llama-cpp.packages.x86_64-linux.rocm.overrideAttrs (old: {
         preConfigure = ''
           mkdir -p build/tools/ui/dist
           cp ${pkgs.fetchurl {
             url = "https://huggingface.co/buckets/ggml-org/llama-ui/resolve/latest/index.html?download=true";
             hash = "sha256:3ea56dac69456ecc2f31ad84d9e912155ae37f247a248d7f28107a22d6bc4af3";
           }} build/tools/ui/dist/index.html
           cp ${pkgs.fetchurl {
             url = "https://huggingface.co/buckets/ggml-org/llama-ui/resolve/latest/bundle.js?download=true";
             hash = "sha256:df068ddb4f64a4ce0c53118301ce8e7cf68bab59a18f0a1f5ee05aea72099e79";
           }} build/tools/ui/dist/bundle.js
           cp ${pkgs.fetchurl {
             url = "https://huggingface.co/buckets/ggml-org/llama-ui/resolve/latest/bundle.css?download=true";
             hash = "sha256:4eb1d456ea3265351c01b5aa3d7706d215d1e4cefc2fb70de58f7d703d36c17b";
           }} build/tools/ui/dist/bundle.css
           cp ${pkgs.fetchurl {
             url = "https://huggingface.co/buckets/ggml-org/llama-ui/resolve/latest/loading.html?download=true";
             hash = "sha256:2500057e39ab81518d16b28f5d019f6107b58abb47b2a30d33862d9e7b703cdc";
           }} build/tools/ui/dist/loading.html
         '';
       }))
     ];
   }
