Plugin.define do
  name    "redcar_air"
  version "0.1"
  file    "lib", "redcar_air"
  object  "Redcar::RedcarAir"
  dependencies "redcar", ">0"
end