(**************************************************************************)
(*                                                                        *)
(*   Typerex Tools                                                        *)
(*                                                                        *)
(*   Copyright 2011-2017 OCamlPro SAS                                     *)
(*                                                                        *)
(*   All rights reserved.  This file is distributed under the terms of    *)
(*   the GNU General Public License version 3 described in the file       *)
(*   LICENSE.                                                             *)
(*                                                                        *)
(**************************************************************************)

open StringCompat
open BuildValue.Types
open BuildOCPTree

module Init(S: sig

    val filesubst : (string * env list) StringSubst.M.subst

  end) : sig

  val primitives : ((env list -> env -> plist) * string list) StringMap.t ref
  val primitives_help : unit -> string list StringCompat.StringMap.t

end