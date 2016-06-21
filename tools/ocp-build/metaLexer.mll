{
(**************************************************************************)
(*                                                                        *)
(*                              OCamlPro TypeRex                          *)
(*                                                                        *)
(*   Copyright OCamlPro 2011-2016. All rights reserved.                   *)
(*   This file is distributed under the terms of the GPL v3.0             *)
(*      (GNU Public Licence version 3.0).                                 *)
(*                                                                        *)
(*     Contact: <typerex@ocamlpro.com> (http://www.ocamlpro.com/)         *)
(*                                                                        *)
(*  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,       *)
(*  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES       *)
(*  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND              *)
(*  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS   *)
(*  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN    *)
(*  ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN     *)
(*  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE      *)
(*  SOFTWARE.                                                             *)
(**************************************************************************)


type token =
| STRING of string
| IDENT of string
| LPAREN
| RPAREN
| PLUSEQUAL
| EQUAL
| MINUS
| EOF

  exception Error

  let str_buf = Buffer.create 1000
}

let blank = [' ' '\010' '\013' '\009' '\012']
let firstidentchar = ['a'-'z' '\223'-'\246' '\248'-'\255' '_' 'A'-'Z' '\192'-'\214' '\216'-'\222']
let identchar =
  ['A'-'Z' 'a'-'z' '_' '\192'-'\214' '\216'-'\246' '\248'-'\255' '\'' '0'-'9'
 '.']
let symbolchar =
  ['!' '$' '%' '&' '*' '+' '-' '.' '/' ':' '<' '=' '>' '?' '@' '^' '|' '~']
let symbolchar2 =
  ['!' '$' '%' '&' '*' '+' '-' '.' '/' '<' '=' '>' '?' '@' '^' '|' '~']
(*  ['!' '$' '&' '*' '+' '-' '.' '/' ':' '<' '=' '>' '?' '@' '^' '|' '~'] *)
let decimal_literal = ['0'-'9']+
let hex_literal = '0' ['x' 'X'] ['0'-'9' 'A'-'F' 'a'-'f']+
let oct_literal = '0' ['o' 'O'] ['0'-'7']+
let bin_literal = '0' ['b' 'B'] ['0'-'1']+
let float_literal =
  ['0'-'9']+ ('.' ['0'-'9']* )? (['e' 'E'] ['+' '-']? ['0'-'9']+)?

rule token = parse
  blank + { token lexbuf }
  | ',' { token lexbuf }
  | '#' [^ '\n' ]* ('\n' | eof) { token lexbuf }
  | '(' { LPAREN }
  | ')' { RPAREN }
  | "+=" { PLUSEQUAL }
  | '=' { EQUAL }
  | firstidentchar identchar+ {
    IDENT (Lexing.lexeme lexbuf)
  }
  | '"' { Buffer.clear str_buf; string lexbuf }
  | '-' { MINUS }
  | eof   { EOF }
  | _ {
    Printf.fprintf stderr "Unexpected lexeme %S\n%!" (Lexing.lexeme lexbuf);
    raise Error }

and string = parse
    |  '"' { STRING (Buffer.contents str_buf) }
    | '\\' [ '\\' '"' ] { Buffer.add_char str_buf '"'; string lexbuf }
    | [^ '"' '\\']+
        { Buffer.add_string str_buf (Lexing.lexeme lexbuf); string lexbuf }
