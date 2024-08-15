%skeleton "lalr1.cc"
%require "3.8.2"
%defines
%define api.parser.class {calcxx_parser}
%define api.token.constructor
%define api.value.type variant
%define parse.assert

%code requires
{
  class calcxx_driver;

  #include <string>
  #include <utility>
  #include <variant>
  #include <vector>
  #include <unordered_map>
  #include <queue>
  #include <cvc5/cvc5.h>
	

  //since the parser is the root dependency
  //any global aliases are better placed here

  using pair_of_strings = std::pair<std::string,std::string>;
  using sort_or_string = std::variant<cvc5::Sort,std::string>;


  struct SortString {
      std::string value;
      SortString(const std::string& s) : value{s} {}
      SortString() = default;
  };

  struct SetString {
      std::string value;
      SetString(const std::string& s) : value{s} {}
      SetString() = default;
  };



  using sort_or_aux = std::variant<
      SortString,
      SetString,
      pair_of_strings,
      std::vector<sort_or_string>,
      cvc5::Sort
    >;
  using pair_string_sort = std::pair<std::string,sort_or_aux>;

  using record_map_aux = std::unordered_map<std::string,sort_or_aux>;
  using record_map     = std::unordered_map<std::string,cvc5::Sort>;

  using pair_string_rec = std::pair<std::string,record_map_aux>;

  using vec_pair_strings = std::vector<pair_of_strings>;


}


%param { calcxx_driver& driver }

%locations

%initial-action
{
  @$.begin.filename = @$.end.filename = &driver.file;
}

%define parse.trace
%define parse.error verbose

%code
{
  #include "diorama_driver.hpp"

  // zom = zero or more
  // wom = one  or more
  // zow = zero or won
  // wom = one  or more

}

%define api.token.prefix {TOK_} 
%token
EOF 0      "end of file"
H1         "#"
H2         "##"
H3         "###"
H4         "####"
H5         "#####"
BLD        "**"
MEMBERS    "members" 
ARE        "are"
END        "end"
ASSIGN     ":="
MINUS      "-"
PLUS       "+"
STAR       "*"
SLASH      "/"
LPAREN     "("
RPAREN     ")"
MODULE     "module"
IS         "is"
RECORD     "record"
COLON      ":"
COMMA      ","
GT         "<"
LT         ">"
PERIOD     "."
IN         "in"
ISSETOF    "is-set-of"
START      "start"
MAPS       "maps"
TO         "to"
FOR        "for"
RULE       "rule"
OR         "or"
WHEN       "when"
THEN       "then"
ANY        "any"
ALL        "all"         
AT         "at" 
MOST       "most" 
LEAST      "least"
ALWAYS     "always"
IF         "if"   
ELSE       "else"
SOME       "some"
SUCH       "such"
THAT       "that"
TICK       "'"
AND        "and"
ORRATHER   "or-rather"
NOT        "not"
EQ         "equals"
NOTEQ      "not-equals"
UNION      "unions" 
INTERSECT  "intersects" 
DIFF       "differences" 
ISIN       "is-in" 
ISSUB      "is-subset" 
COMP       "compliments"
ISGT       "is-greater-than" 
ISLT       "is-less-than"
BTWN       "between" 
XOR        "or-equals"
DOTDOT     ".."
RBRCKT     "]"
LBRCKT     "[" 
ARROW      "->"
LBRACE     "{"
RBRACE     "}"
;



%token <std::string> WORD
%token <int> INT
%token <cvc5::Term> FALSE 
%token <cvc5::Term> TRUE
%token FLOAT 

%type <cvc5::Term> name_sel 
%type <cvc5::Term> tuple_val 
%type <cvc5::Term> enum_val
%type <cvc5::Term> atom


%type <pair_string_sort> declaration 
%type <pair_string_sort> named_decl 
%type <pair_string_sort> set_decl 
%type <pair_string_sort> array_decl 
%type <pair_string_sort> tuple_decl 
%type <pair_string_sort> enum_decl

%type <std::vector<std::string>> wom_enums wom_types wom_sel
%type <std::vector<pair_string_sort>> wom_decleration

%type <std::string> word_or_members 

%printer { yyoutput << "todo"; } <cvc5::Term>;
%printer { yyoutput << "todo"; } <std::vector<pair_string_sort>>;
%printer { yyoutput << "todo"; } <pair_of_strings>;
%printer { yyoutput << "todo"; } <vec_pair_strings>;
%printer { yyoutput << "todo"; } <std::vector<std::string>>;
%printer { yyoutput << "todo"; } <pair_string_sort>;
%printer { yyoutput << $$; } <*>;

%start spec

%%

spec : module

module :  "module" WORD "is" data body "end" WORD {
  switch (driver.p) {
    case phase1: {
      
      if ( ! driver.members_declared ) { /*TODO: throw */ }

      int aux_processing_iterrations = driver.aux_string_rec_map.size();
      aux_processing_iterrations = aux_processing_iterrations * aux_processing_iterrations + 1;

      //TODO: eventually factor these out into functions

      for ( int i=0; i < aux_processing_iterrations+1; i+= 1) {

        if ( driver.aux_string_rec_map.empty() ) { 
            break;
        }

        //first  = string name
        //second = aux record
        pair_string_rec record_tmp = driver.aux_string_rec_map.front();
        driver.aux_string_rec_map.pop();
        bool all_sorts_known = true;


        for ( auto& [field,sort] : record_tmp.second ) {

          if ( std::holds_alternative<SortString>(sort) ) {

            auto tmp_sort_string { std::get<SortString>(sort) };

            if ( driver.string_sort_map.contains( tmp_sort_string.value ) ){
              sort = driver.string_sort_map[tmp_sort_string.value];
            }
            else {
              all_sorts_known = false;
            }

          }
          else if ( std::holds_alternative<SetString>(sort) ) {

            auto set_string { std::get<SetString>(sort) };

            if ( driver.string_sort_map.contains( set_string.value ) ){
              sort = driver.string_sort_map[set_string.value];
            }
            else {
              all_sorts_known = false;
            } 


          }
          else if ( std::holds_alternative<pair_of_strings>(sort) ) {

            auto tmp_dom{ std::get<pair_of_strings>(sort).first };
            auto tmp_rng{ std::get<pair_of_strings>(sort).second };

            if ( driver.string_sort_map.contains( tmp_dom ) &&
                 driver.string_sort_map.contains( tmp_rng )   ) {

                 
                auto array_sort = driver.slv->mkArraySort(
                  driver.string_sort_map[tmp_dom],
                  driver.string_sort_map[tmp_rng]
                ); 

                sort = array_sort;

            }
            else {
              all_sorts_known = false;
            }


          }
          else if ( std::holds_alternative<std::vector<sort_or_string>>(sort) ) {

            auto tmp_sorts { std::get<std::vector<sort_or_string>>(sort) };
            std::vector<sort_or_string> sorts_for_tuple;

            for ( auto & sort_t : tmp_sorts ) {
                auto sort_string { std::get<std::string>(sort_t) };
                if ( driver.string_sort_map.contains(sort_string) ) {
                    sorts_for_tuple.emplace_back( 
                        driver.string_sort_map[sort_string]
                    );
                }
                else {
                    sorts_for_tuple.emplace_back(sort_t);
                    all_sorts_known = false;
                }
            }

            if ( all_sorts_known ) {

              std::vector<cvc5::Sort> tmp_sorts_for_tuple;
              for ( const auto & sort : sorts_for_tuple ) {
                  tmp_sorts_for_tuple.emplace_back(std::get<cvc5::Sort>(sort));
              }

              auto tuple_sort = driver.slv->mkTupleSort( tmp_sorts_for_tuple ) ;
              sort = tuple_sort;

            }

          }


        }

        if ( all_sorts_known ) {

          auto rec_decl = driver.slv->mkDatatypeDecl(record_tmp.first);
          auto fields = driver.slv->mkDatatypeConstructorDecl(acc::fields);

          for (const auto & [ field, sort ] : record_tmp.second) {
              fields.addSelector(field, std::get<cvc5::Sort>(sort));
          }

          rec_decl.addConstructor(fields);

          auto rec_sort = driver.slv->mkDatatypeSort(rec_decl);    

          driver.string_sort_map[record_tmp.first] = rec_sort;

        }
        else {
          
          driver.aux_string_rec_map.push(record_tmp);

        }

      }


    }
    break;
    default: break;
  }
}


// todo: eventually test out of order decleration,
// todo: mix data and body under univeral_block

data : wom_schemes
body : inits zom_rules

wom_schemes : wom_schemes scheme | scheme
scheme : record_decl
       | enum_decl

word_or_members : WORD | "members" { $$ = std::string("members"); }

record_decl : "record" word_or_members "are" wom_decleration "end" "record" {
     switch (driver.p) {
      case phase1: {

        //TODO: cover already declared case
        //for now we assume it hasnt already been declared

        record_map_aux record_var;
        bool all_sorts_known = true;

        for (const auto & row: $4){

            if ( std::holds_alternative<cvc5::Sort>(row.second) ){
                record_var[row.first] = std::get<cvc5::Sort>(row.second);
            }
            else {
                record_var[row.first] = row.second;
                all_sorts_known = false;
            }

        }
        // we declare & construct a record of the sort 
        // that is composed of known sorts
        if ( all_sorts_known ) {

            auto rec_decl = driver.slv->mkDatatypeDecl($2);
            auto fields = driver.slv->mkDatatypeConstructorDecl(acc::fields);

            for (const auto & [ field, sort ] : record_var) {
                fields.addSelector(field, std::get<cvc5::Sort>(sort));
            }

            rec_decl.addConstructor(fields);

            auto rec_sort = driver.slv->mkDatatypeSort(rec_decl);


            if ( $2 == "members" ){

              driver.members = driver.slv->mkConst(rec_sort,"members");
              driver.members_declared = true;

            }
            else {

              driver.string_sort_map[$2] = rec_sort;

            }


        }
        //else we append to auxiallry structure
        else {

          driver.aux_string_rec_map.emplace( 
            std::make_pair($2,record_var)
          );

        }

      };
      break;
      default: break;
    }
};
 

enum_decl : WORD "are" "<" wom_enums ">" {
          switch (driver.p) {
            case phase1: {

              auto enum_spec = driver.slv->mkDatatypeDecl($1);

              std::vector<cvc5::DatatypeConstructorDecl> enum_ctrs;
              for (const auto & val: $4){
                  enum_ctrs.emplace_back(
                    driver.slv->mkDatatypeConstructorDecl(val)
                  );
              }

              for (const auto & ctor: enum_ctrs){
                  enum_spec.addConstructor(ctor);
              }

              auto enum_sort = driver.slv->mkDatatypeSort(enum_spec);
              driver.string_sort_map[$1] = enum_sort;

            }
            break;
            default: break;
          }
};
wom_enums : wom_enums "," WORD {
  switch (driver.p) {
    case phase1: {
      $$ = $1;
      $$.emplace_back($3);
    }
    break;
    default: break;
  }
};
| WORD {
  switch (driver.p) {
    case phase1: {
      std::vector<std::string> t;
      t.emplace_back($1);
      $$ = t;
    } break;
      default: break;
  }
};


wom_decleration : wom_decleration declaration {

  switch (driver.p) {
    case phase1: {
      $$ = $1;
      $$.emplace_back($2);
    }
    break;
    default: break;
  }

};  | declaration {
    switch (driver.p) {
      case phase1: {
        std::vector<pair_string_sort> t;
        t.emplace_back($1);
        $$ = t;
      } break;
        default: break;
    }
};

declaration : named_decl "."
            | set_decl "."
            | array_decl "."
            | tuple_decl "."

named_decl : WORD either_in_or_is WORD {    
    switch (driver.p)
    {
        case phase1: {
          std::string name {$1};
          SortString sort_string($3);

          if ( driver.string_sort_map.contains(sort_string.value) ){

              $$ = std::make_pair(
                name,
                driver.string_sort_map[sort_string.value]
              );

          }
          else {

              $$ = std::make_pair(name,sort_string);

          }
          
        }
        break;
      
      default: break;
    }
      
};
set_decl : WORD "is-set-of" WORD {
    switch (driver.p)
    {
        case phase1: {
          std::string name {$1};
          SetString set_string($3);

          if ( ! driver.string_sort_map.contains(set_string.value) ){

              $$ = std::make_pair(name,set_string);

          }
          else {
              auto set_sort = driver.slv->mkSetSort(
                driver.string_sort_map[set_string.value]
              );
              $$ = std::make_pair(name,set_sort);
          }
          
        }
        break;
      default: break;
    }

};
//TODO: second word can be expression
array_decl  : WORD "maps" WORD "to" WORD {
   switch (driver.p)
    {
        case phase1: {
          std::string name {$1};
          std::string dom_string {$3};
          std::string rng_string {$3};

          if ( ! driver.string_sort_map.contains(dom_string) &&
               ! driver.string_sort_map.contains(rng_string)    ){

                auto array_string = std::make_pair(dom_string,rng_string);
                $$ = std::make_pair(name,array_string);
          }
          else {

            auto array_sort = driver.slv->mkArraySort(
              driver.string_sort_map[dom_string],
              driver.string_sort_map[rng_string]
            );

            $$ = std::make_pair(name,array_sort);
          }
        }
        break;
      default: break;
    }
};
tuple_decl  : WORD either_in_or_is "(" wom_types ")" {
  switch (driver.p) {
    case phase1: {
      
      bool all_sorts_known = true;
      std::vector<sort_or_string> sorts_for_tuple;

      for ( const auto & sort : $4 ) {
          if ( driver.string_sort_map.contains(sort) ) {
              sorts_for_tuple.emplace_back( 
                  driver.string_sort_map[sort]
               );
          }
          else {
              sorts_for_tuple.emplace_back(sort);
              all_sorts_known = false;
          }
      }

      if ( all_sorts_known ) {

          std::vector<cvc5::Sort> tmp_sort;
          for ( const auto & sort : sorts_for_tuple ) {
              tmp_sort.emplace_back(std::get<cvc5::Sort>(sort));
          }

          auto tuple_sort = driver.slv->mkTupleSort( tmp_sort ) ;
          $$ = std::make_pair($1,tuple_sort);

      }
      else {
        
        $$ = std::make_pair($1,sorts_for_tuple);

      }

    }
    break;
    default: break;
  }
};
wom_types  : wom_types "," WORD {
  switch (driver.p) {
    case phase1: {
      $$ = $1;
      $$.emplace_back($3);
    }
    break;
    default: break;
  }
};
| WORD {
  switch (driver.p) {
    case phase1: {
      std::vector<std::string> t;
      t.emplace_back($1);
      $$ = t;
    } break;
      default: break;
  }
};





//TODO: wom_elements -> wom_terms

either_in_or_is : "in" | "is"

inits : zom_inits member_init

zom_inits : %empty | zom_inits init
init : struct_init | array_init
array_init  : "start" "for" WORD "is" array_map_init "end" "start"
struct_init : "start" "for" WORD "is" basic_init "end" "start"
member_init : "start" "for" "members" "is" basic_init "end" "start"

array_map_init : wom_structure_mapping
basic_init : wom_word_to_structure_mapping

wom_structure_mapping  : wom_structure_mapping "," structure_mapping | structure_mapping
structure_mapping : structure ":=" structure

wom_word_to_structure_mapping : wom_word_to_structure_mapping "," word_to_structure | word_to_structure
word_to_structure :  WORD ":=" structure 


zom_rules : %empty | zom_rules rule
optional_word : %empty | WORD
rule : "rule" optional_word "is" when_blocks then_blocks "end" "rule"
when_blocks : wom_when_blocks
wom_when_blocks : wom_when_blocks "or" when_block | when_block
then_blocks : wom_then_blocks
wom_then_blocks : wom_then_blocks "or" then_block | then_block
when_block : "when" zow_quantifier ":" zom_determining_exprs
zow_quantifier : %empty | quantifier
zom_determining_exprs : %empty | zom_determining_exprs determining_exprs
then_block : "then" ":" wom_stmts
wom_stmts : wom_stmts stmt | stmt

determining_exprs : "-" expr "."

quantifier : "any"        
           | "all"        
           | "at" "most"  
           | "at" "least" 
           | "always"     
//TODO: add or equal to to at most or at least
     
stmt : if_stmt
     | selection_stmt "."
     | assignment "." 

if_stmt : "if" expr "then" ":" wom_stmts zom_else_if zow_else "end" "if"
zom_else_if : %empty | zom_else_if else_if
else_if : "else" "if" expr "then" ":" wom_stmts
zow_else : %empty | else
else    : "else" ":" wom_stmts

selection_stmt : "for" WORD "in" expr zow_filter
               | "for" "some" WORD "in" expr zow_filter
               | "for" "all" WORD "in" expr zow_filter
zow_filter : %empty | filter
filter : "such" "that" expr 

assignment : lhs_member "'" ":=" expr

expr  : equality
      | expr "and" equality
      | expr "or" equality
      | expr "or-rather" equality
      | "not" expr

equality  : set_opers
          | equality "equals" set_opers
          | equality "not-equals" set_opers

set_opers  : membership
           | set_opers "unions" membership
           | set_opers "intersects" membership
           | set_opers "differences" membership
           | set_opers "is-in" membership
           | set_opers "is-subset" membership
           | "compliments" set_opers

membership  : arithmatic
            | membership "is-greater-than" zow_or_equals arithmatic
            | membership "is-less-than" zow_or_equals arithmatic
            | membership zow_is "between" range
zow_is : %empty | "is"
zow_or_equals : %empty | "or-equals"


range  :     arithmatic ".." arithmatic
       | "(" arithmatic ".." arithmatic ")"
       | "(" arithmatic ".." arithmatic "]"
       | "[" arithmatic ".." arithmatic ")"
       | "[" arithmatic ".." arithmatic "]"

arithmatic  : term
            | arithmatic "+" term
            | arithmatic "-" term
            | arithmatic "*" term
            | arithmatic "/" term


name_sel  : WORD {

  switch (driver.p) {
    case phase2: { 
      std::string member_name{ $1 };

      auto mem_sel = driver.members 
                           .getSort()
                           .getDatatype()[acc::fields]
                           .getSelector(member_name)
                           .getTerm(); 

      std::cout << mem_sel << std::endl;
      std::cout << driver.members.getNumChildren() << std::endl;
      
      auto field_term = driver.slv->mkTerm(
          cvc5::Kind::APPLY_SELECTOR,
          { mem_sel , driver.members }
      );

      $$ = field_term;
    }break;

    default: break;
  };

};
  | WORD wom_sel {

    switch (driver.p) {
      case phase2: {
        
       std::string member_name = std::string($1);
       std::vector<std::string> selectors_vec { $2 };
       auto mem_sel = driver.members 
                            .getSort()
                            .getDatatype()
                            .getSelector(member_name)
                            .getTerm();
        
        auto field_term = driver.slv->mkTerm(
            cvc5::Kind::APPLY_SELECTOR,
            { mem_sel, driver.members }
        );

        auto curr_sel    { mem_sel };    //cvc5 selector
        auto temp_term   { field_term }; //cvc5 term
        for ( std::size_t i = 1; i < selectors_vec.size() ; i+= 1 ) {

          std::string next_sel_name = selectors_vec[i] ;

          curr_sel = curr_sel 
                     .getSort() 
                     .getDatatype()
                     .getSelector(next_sel_name) 
                     .getTerm();

          temp_term = driver.slv->mkTerm(
              cvc5::Kind::APPLY_SELECTOR,
              { curr_sel, temp_term }
          );
        }

        // vec is never empty via grammar rules
        std::string field_to_sel { selectors_vec.back() }; 

        curr_sel = temp_term 
                     .getSort() 
                     .getDatatype()
                     .getSelector(field_to_sel) 
                     .getTerm();

        field_term = driver.slv->mkTerm(
            cvc5::Kind::APPLY_SELECTOR,
            { curr_sel, temp_term }
        );
        
        $$ = field_term;

      };
      break;
      default: break;
    };


};

lhs_member  : WORD | WORD wom_sel

wom_sel : wom_sel "->" WORD {
  switch (driver.p) {
    case phase2: {
      $$ = $1;
      $$.emplace_back($3);
    };
    break;
    default: break;
  };
};      | "->" WORD {
  switch (driver.p) {
    case phase2: {
      std::vector<std::string> t;
      t.emplace_back($2);
      $$ = t;
    };
    break;
    default: break;
  };
}

term  : atom
      | "(" expr ")"

structure : atom | "{" wom_structure_row "}"
wom_structure_row : wom_structure_row "," structure_row | structure_row
structure_row : WORD ":" structure
atom : INT {
  switch (driver.p) {
    case phase2: {
      $$ = driver.slv->mkInteger($1);
    };
    break;
    default: break;
  };
}; | FLOAT {
  //TODO: float -> bitvector nonsense
};
   | name_sel {

};
   | tuple_val {}
   | FALSE 
   | TRUE 
   | enum_val {}

enum_val : name_sel "<" WORD ">"
tuple_val : "(" wom_atom  ")"
wom_atom : wom_atom "," atom | atom


//TODO: ensure members can only be declared once
//TODO: -Wcounterexamples

%%

void yy::calcxx_parser::error(const location_type &l, const std::string &m)
{
  driver.error(l, m);
}
