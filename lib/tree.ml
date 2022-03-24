exception Duplicate
exception NotFound

type 'a tree =
  | EmptyLeaf
  | Leaf of (int * 'a)
  | Node of (int * 'a * 'a tree * 'a tree)

let empty = EmptyLeaf

let is_empty = function
  | EmptyLeaf -> true
  | _ -> false

let rec size = function
  | EmptyLeaf -> 0
  | Leaf _ -> 1
  | Node (_, _, l, r) -> 1 + size l + size r

let rec get key = function
  | EmptyLeaf -> raise NotFound
  | Leaf (k, v) -> if k = key then v else raise NotFound
  | Node (k, v, l, r) ->
      if k = key then v else if k < key then get key r else get key l

let rec insert key_value_pair tree =
  let key = fst key_value_pair in
  let value = snd key_value_pair in
  match tree with
  | EmptyLeaf -> Node (key, value, EmptyLeaf, EmptyLeaf)
  | Leaf (k, v) ->
      if k = key then raise Duplicate
      else
        let new_leaf = Leaf (key, value) in
        if k < key then Node (k, v, EmptyLeaf, new_leaf)
        else Node (k, v, new_leaf, EmptyLeaf)
  | Node (k, v, l, r) ->
      if k = key then raise Duplicate
      else
        let new_leaf = Leaf (key, value) in
        if k < key then
          if is_empty r then Node (k, v, l, new_leaf)
          else Node (k, v, l, insert (key, value) r)
        else if is_empty l then Node (k, v, new_leaf, r)
        else Node (k, v, insert (key, value) l, r)

let rec get_min = function
  | EmptyLeaf -> raise NotFound
  | Leaf (k, v) -> (k, v)
  | Node (_, _, l, _) -> get_min l

let rec delete key = function
  | EmptyLeaf -> raise NotFound
  | Leaf (k, v) -> if k = key then EmptyLeaf else raise NotFound
  | Node (k, v, l, r) ->
      if k = key then
        if is_empty l then r
        else if is_empty r then l
        else
          let new_k, new_v = get_min r in
          Node (new_k, new_v, l, delete new_k r)
      else if k < key then Node (k, v, l, delete key r)
      else Node (k, v, delete key l, r)

let rec inorder = function
  | EmptyLeaf -> []
  | Leaf (k, v) -> [ (k, v) ]
  | Node (k, v, l, r) -> inorder l @ [ (k, v) ] @ inorder r

let rec fold f init = function
  | EmptyLeaf -> init
  | Leaf (k, v) -> f init v init
  | Node (k, v, l, r) ->
      let l' = fold f init l in
      let r' = fold f init r in
      f l' v r'

let filter f tree =
  let all_key_value_pairs = inorder tree in
  let rec filter_helper f key_value_pairs =
    match key_value_pairs with
    | [] -> []
    | h :: t ->
        if f (snd h) then h :: filter_helper f t else filter_helper f t
  in
  let filtered_pairs = filter_helper f all_key_value_pairs in
  let rec generate_tree tree alist =
    match alist with
    | [] -> EmptyLeaf
    | h :: t -> insert h (generate_tree tree t)
  in
  generate_tree empty filtered_pairs  

let rec generate_new_key = function
  | EmptyLeaf -> 0
  | Leaf (k, v) -> k + 1
  | Node (k, v, l, r) -> generate_new_key r
