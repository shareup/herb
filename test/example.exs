#! /usr/bin/env herb

IO.inspect({:argv, System.argv()})

Herb.package(:jason, "1.1.2")

IO.inspect({:decoded_json_map, Jason.decode!("{}")})
