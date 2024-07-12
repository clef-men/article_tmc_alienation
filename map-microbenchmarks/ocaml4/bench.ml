(* This benchmark code is derived from faster-map:
   https://github.com/aantron/faster-map
*)

let impls = [
  "naive-nontail", Impls.Naive_nontail.map;
  "naive-tail", Impls.Naive_tail.map;
  "base", Impls.Base.map;
  "containers", Impls.Containers.map;
  "batteries", Impls.Batteries.map;
  "tmc", Impls.TMC.map;
  "unrolled", Impls.TMC_unrolled.map;
]

let test map =
  let count = ref 0 in
  assert (map (fun i -> incr count; i + !count) [1; 2; 3] = [2; 4; 6])

let () =
  List.iter (fun (_, impl) -> test impl) impls

let list_sizes =
  let rec log_steps ~lower:exponent ~upper ~step =
    if exponent > upper then []
    else
      let size = int_of_float (10. ** exponent) in
      size :: log_steps ~lower:(exponent +. step) ~upper ~step
  in
  [0; 1; 2; 3; 5;]
  @ log_steps ~lower:1. ~upper:4. ~step:0.25
  @ log_steps ~lower:4.1 ~upper:4.9 ~step:0.1
  @ log_steps ~lower:5. ~upper:6. ~step:0.25

let old = ref []

let make_map_test name map_function argument : Core_bench.Bench.Test.t =
  Core_bench.Bench.Test.create
    ~name
    (fun () ->
      old := map_function ((+) 1) argument)

let make_argument_list number_of_elements =
  List.init number_of_elements Fun.id

let make_tests map_functions list_sizes : (int * Core.Command.t) list =
  list_sizes
  |> List.map (fun list_size ->
    let argument_list = make_argument_list list_size in
    map_functions
    |> List.map (fun (name, map_function) ->
      make_map_test name map_function argument_list)
    |> Core_bench.Bench.make_command
    |> fun command -> (list_size, command))

let () =
  make_tests impls list_sizes
  |> List.iter (fun (list_size, test) ->
    Printf.printf "With lists of size %i\n%!" list_size;
    Command_unix.run test)
