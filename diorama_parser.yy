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
  #include <map>
  #include <queue>
  #include <optional>
  #include <tuple>
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

  // we use map since insertions are odered
  using record_map_aux = std::map<std::string,sort_or_aux>;

  using pair_string_term = std::pair<std::string,cvc5::Term>;

  using pair_string_rec = std::pair<std::string,record_map_aux>;

  using vec_pair_strings = std::vector<pair_of_strings>;



  enum class quant { any, all, at_least, at_most, always };

  using cond_op_and_limit = std::pair<quant,int>;

  using range_type = std::tuple<
    cvc5::Kind,cvc5::Kind,
    cvc5::Term,cvc5::Term
  >;

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

%type <cvc5::Term> tuple_val
%type <cvc5::Term> enum_val
%type <cvc5::Term> lhs_name_sel rhs_name_sel

%type <cvc5::Term> atom term structure expr
%type <cvc5::Term> equality
%type <cvc5::Term> set_opers
%type <cvc5::Term> membership
%type <cvc5::Term> arithmatic
%type <cvc5::Term> determining_exprs
%type <cvc5::Term> stmt
%type <cvc5::Term> if_stmt
%type <cvc5::Term> selection_stmt
%type <cvc5::Term> assignment

%type <range_type> range

%type <pair_string_sort> declaration
%type <pair_string_sort> named_decl
%type <pair_string_sort> set_decl
%type <pair_string_sort> array_decl
%type <pair_string_sort> tuple_decl
%type <pair_string_sort> enum_decl

%type <pair_string_term> word_to_structure

%type <std::vector<std::string>> wom_enums wom_types wom_sel
%type <std::vector<pair_string_sort>> wom_decleration
%type <std::vector<pair_string_term>> wom_word_to_structure_mapping basic_init
%type <std::vector<cvc5::Term>> wom_stmts zom_determining_exprs wom_when_blocks
%type <std::vector<std::vector<cvc5::Term>>> wom_then_blocks
%type <std::vector<cvc5::Term>> then_block
%type <cvc5::Term> when_block


%type <cond_op_and_limit> quantifier
%type <std::optional<cond_op_and_limit>> zow_quantifier
%type <std::optional<bool>> zow_or_equals
%type <std::string> word_or_members
%type <std::optional<std::string>> zow_word

%printer { yyoutput << "todo"; } <cvc5::Term>;
%printer { yyoutput << "todo"; } <std::vector<pair_string_sort>>;
%printer { yyoutput << "todo"; } <std::vector<pair_string_term>>;
%printer { yyoutput << "todo"; } <std::vector<std::string>>;
%printer { yyoutput << "todo"; } <std::vector<cvc5::Term>>;
%printer { yyoutput << "todo"; } <std::vector<std::vector<cvc5::Term>>>;
%printer { yyoutput << "todo"; } <pair_string_term>;
%printer { yyoutput << "todo"; } <std::optional<bool>>;
%printer { yyoutput << "todo"; } <std::optional<cond_op_and_limit>>;
%printer { yyoutput << "todo"; } <range_type>;
%printer { yyoutput << "todo"; } <std::optional<std::string>>;
%printer { yyoutput << "todo"; } <cond_op_and_limit>;
%printer { yyoutput << "todo"; } <pair_string_sort>;
%printer { yyoutput << $$; } <*>;

%start spec

%%

spec : module

module :  "module" WORD "is" data body "end" WORD {
    if (driver.p == phase1) {

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


                auto array_sort = driver.tm->mkArraySort(
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

              auto tuple_sort = driver.tm->mkTupleSort( tmp_sorts_for_tuple ) ;
              sort = tuple_sort;

            }

          }


        }

        if ( all_sorts_known ) {

          auto rec_decl = driver.tm->mkDatatypeDecl(record_tmp.first);
          auto fields = driver.tm->mkDatatypeConstructorDecl(acc::fields);

          for (const auto & [ field, sort ] : record_tmp.second) {
              fields.addSelector(field, std::get<cvc5::Sort>(sort));
          }

          rec_decl.addConstructor(fields);

          auto rec_sort = driver.tm->mkDatatypeSort(rec_decl);

          driver.string_sort_map[record_tmp.first] = rec_sort;

        }
        else {

          driver.aux_string_rec_map.push(record_tmp);

        }

      }

      //map members to map
      //TODO: struct map
      /*
      for ( const auto& [_,rec] : driver.string_sort_map ) {

        if ( rec.isDatatype() ) {

          std::vector<std::string> rec_members;

          for ( const auto& mem_sel : rec.getDatatype()[acc::fields] ) {

            //sorted insert
            rec_members.insert(
              std::upper_bound(rec_members.begin(),rec_members.end(),mem_sel.getName()),
              mem_sel.getName()
            );

          }

          //driver.record_members_map

        }

      }
      */


    }
};


// todo: eventually test out of order decleration,
// todo: mix data and body under univeral_block

data : wom_schemes
body : inits zom_rules

wom_schemes : wom_schemes scheme | scheme
scheme : record_decl
       | enum_decl

word_or_members : WORD | "members" { $$ = std::string("members"); }

record_decl : "record" word_or_members "are" wom_decleration "end" "record" {
      if (driver.p == phase1) {

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

            auto rec_decl = driver.tm->mkDatatypeDecl($2);
            auto fields = driver.tm->mkDatatypeConstructorDecl(acc::fields);

            for (const auto & [ field, sort ] : record_var) {
                fields.addSelector(field, std::get<cvc5::Sort>(sort));
            }

            rec_decl.addConstructor(fields);

            auto rec_sort = driver.tm->mkDatatypeSort(rec_decl);


            if ( $2 == "members" ){

              driver.members_const = driver.tm->mkConst(
                rec_sort,
                "members"
              );
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

      }
};


enum_decl : WORD "are" "<" wom_enums ">" {
  if (driver.p == phase1) {

    auto enum_spec = driver.tm->mkDatatypeDecl($1);

    std::vector<cvc5::DatatypeConstructorDecl> enum_ctrs;
    for (const auto & val: $4){
        enum_ctrs.emplace_back(
          driver.tm->mkDatatypeConstructorDecl(val)
        );
    }

    for (const auto & ctor: enum_ctrs){
        enum_spec.addConstructor(ctor);
    }

    auto enum_sort = driver.tm->mkDatatypeSort(enum_spec);
    driver.string_sort_map[$1] = enum_sort;

  }
};
wom_enums : wom_enums "," WORD {
    if (driver.p == phase1) {
      $$ = $1;
      $$.emplace_back($3);
    }
};
| WORD {
    if (driver.p == phase1) {
      std::vector<std::string> t;
      t.emplace_back($1);
      $$ = t;
    }
};


wom_decleration : wom_decleration declaration {
  if (driver.p == phase1) {
    $$ = $1;
    $$.emplace_back($2);
  }
};  | declaration {
  if (driver.p == phase1) {
    std::vector<pair_string_sort> t;
    t.emplace_back($1);
    $$ = t;
  }
};

declaration : named_decl "."
            | set_decl "."
            | array_decl "."
            | tuple_decl "."

named_decl : WORD either_in_or_is WORD {
  if (driver.p == phase1) {
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

};
set_decl : WORD "is-set-of" WORD {
  if (driver.p == phase1) {
    std::string name {$1};
    SetString set_string($3);

    if ( ! driver.string_sort_map.contains(set_string.value) ){

        $$ = std::make_pair(name,set_string);

    }
    else {
        auto set_sort = driver.tm->mkSetSort(
          driver.string_sort_map[set_string.value]
        );
        $$ = std::make_pair(name,set_sort);
    }

  }

};
//TODO: second word can be expression
array_decl  : WORD "maps" WORD "to" WORD {
  if (driver.p == phase1) {
    std::string name {$1};
    std::string dom_string {$3};
    std::string rng_string {$3};

    if ( ! driver.string_sort_map.contains(dom_string) &&
          ! driver.string_sort_map.contains(rng_string)    ){

          auto array_string = std::make_pair(dom_string,rng_string);
          $$ = std::make_pair(name,array_string);
    }
    else {

      auto array_sort = driver.tm->mkArraySort(
        driver.string_sort_map[dom_string],
        driver.string_sort_map[rng_string]
      );

      $$ = std::make_pair(name,array_sort);
    }
  }
};
tuple_decl  : WORD either_in_or_is "(" wom_types ")" {
  if (driver.p == phase1) {

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

        auto tuple_sort = driver.tm->mkTupleSort( tmp_sort ) ;
        $$ = std::make_pair($1,tuple_sort);

    }
    else {

      $$ = std::make_pair($1,sorts_for_tuple);

    }

  }
};
wom_types  : wom_types "," WORD {
  if (driver.p == phase1) {
    $$ = $1;
    $$.emplace_back($3);
  }
};
| WORD {
  if (driver.p == phase1) {
    std::vector<std::string> t;
    t.emplace_back($1);
    $$ = t;
  }
};





//TODO: wom_elements -> wom_terms

either_in_or_is : "in" | "is"

inits : zom_inits members_init

zom_inits : %empty | zom_inits init
init : struct_init | array_init
array_init   : "start" "for" WORD "is" array_map_init "end" "start"
struct_init  : "start" "for" WORD "is" basic_init "end" "start"
members_init : "start" "for" "members" "is" basic_init "end" "start" {
    if(driver.p == phase2) {

      // we inititialize the members & create the restart for members

      //TODO: assert size of keys in init is size of mems
      //      or ignore size mismatch and implement default
      //      initializer and notify user


      std::vector<cvc5::Term> initalizing_terms;

      initalizing_terms.push_back(
        driver.members_const
              .getSort()
              .getDatatype()
              .getConstructor(acc::fields)
              .getTerm()
      );

      // loop through member name to init vec
      for ( const auto& [ _ , init_term ] : $5 ) {
        initalizing_terms.push_back(init_term);
      }

      driver.members_var = driver.tm->mkTerm(
        cvc5::Kind::APPLY_CONSTRUCTOR,
        initalizing_terms
      );

      // make restart function
      auto member_restart_sort = driver.tm->mkFunctionSort(
          {driver.members_const.getSort()},
           driver.members_const.getSort()
      );

      auto member_restart_fn = driver.tm->mkConst(
          member_restart_sort,
          "start_members"
      );

      driver.module_fns["members"] = member_restart_fn;
      //TODO: make restart function
      /*
      auto apply_fn = driver.tm->mkTerm(
          cvc5::Kind::APPLY_UF,
          {member_restart_fn, driver.members_var}
      );
      */


    }
};

array_map_init : wom_structure_mapping
basic_init : wom_word_to_structure_mapping

wom_structure_mapping  : wom_structure_mapping "," structure_mapping | structure_mapping
structure_mapping : structure ":=" structure

wom_word_to_structure_mapping : wom_word_to_structure_mapping "," word_to_structure {
    if(driver.p == phase2) {
      $$ = $1;
      $$.emplace_back($3);
    }
}; | word_to_structure {
    if(driver.p == phase2) {
      std::vector<pair_string_term> t;
      t.emplace_back($1);
      $$ = t;
    }
};

word_to_structure :  WORD ":=" structure {
    if(driver.p == phase2) {
      $$ = std::make_pair($1,$3);
    }
};


zom_rules : %empty | zom_rules rule
zow_word : %empty {
    if (driver.p == phase3){
        $$ = std::nullopt;
    }
}
    | WORD {
    if (driver.p == phase3){
        $$ = $1;
    }
}
rule : "rule" zow_word "is" wom_when_blocks wom_then_blocks "end" "rule" {
    if (driver.p == phase3){

        std::string trigger_name;
        if ( $2.has_value() ) {
            trigger_name = $2.value();
        }
        else {
            trigger_name = "rule_" + std::to_string(driver.rule_count);
            driver.rule_count += 1;
        }

        auto trigger_rule = driver.tm->mkConst(
            driver.tm->getBooleanSort(),
            trigger_name
        );

        // or all when blocks & set equal to trigger
        auto triggers =  driver.tm->mkTerm(
            cvc5::Kind::EQUAL,
            {
                trigger_rule,
                driver.tm->mkTerm(
                    cvc5::Kind::OR, $4
                )
            }
        );
        driver.slv->assertFormula(triggers);

        if ( $5.size() == 1 ) {

            for ( const auto& thens : $5[0] ){
                auto imply_rule = driver.tm->mkTerm(
                    cvc5::Kind::IMPLIES,
                    { trigger_rule , thens }
                );
                driver.slv->assertFormula(imply_rule);
            }

        }
        else {
            std::vector<cvc5::Term> multiplex_triggers;

            for ( std::size_t i = 0; i < $5.size(); i+=1 ) {

                auto multiplexed_trigger =  driver.tm->mkConst(
                    driver.tm->getBooleanSort(),
                    ("mult_" + std::to_string(i))
                );

                auto imply_trigger = driver.tm->mkTerm(
                    cvc5::Kind::IMPLIES,
                    { trigger_rule, multiplexed_trigger}
                );
                driver.slv->assertFormula(imply_trigger);

                for ( const auto& thens : $5[i] ) {

                    auto imply_rule = driver.tm->mkTerm(
                        cvc5::Kind::IMPLIES,
                        { multiplexed_trigger , thens }
                    );
                    driver.slv->assertFormula(imply_rule);

                }

                multiplex_triggers.push_back(multiplexed_trigger);
            }

            driver.slv->assertFormula(
                driver.tm->mkTerm(
                    cvc5::Kind::XOR,
                    multiplex_triggers
                )
            );

        }

    }
}

wom_when_blocks : wom_when_blocks "or" when_block {
    if (driver.p == phase3){
        $$ = $1;
        $$.push_back($3);
    }
}
    | when_block {
    if (driver.p == phase3){
        std::vector<cvc5::Term> t;
        t.push_back($1);
        $$ = t;
    }
}
wom_then_blocks : wom_then_blocks "or" then_block {
    if (driver.p == phase3){
        $$ = $1;
        $$.emplace_back($3);
    }
}   | then_block {
    if (driver.p == phase3){
        std::vector<std::vector<cvc5::Term>> t;
        t.emplace_back($1);
        $$ = t;
    }
}

when_block : "when" zow_quantifier ":" zom_determining_exprs {
    if (driver.p == phase3) {

        int num_of_qualifications_needed = 0;
        auto qualifier = quant::always;

        if ($2.has_value()) {
            qualifier = $2.value().first;
            num_of_qualifications_needed = $2.value().second;
        }

        switch (qualifier)
        {
            case quant::any :{
                $$ = driver.tm->mkTerm(
                    cvc5::Kind::OR, $4
                );
            };
            break;
            case quant::all :{
                $$ = driver.tm->mkTerm(
                    cvc5::Kind::AND, $4
                );
            };
            break;
            case quant::at_least :{
               std::vector<cvc5::Term> count_of_qualifiying_expressions;

                for ( const auto& cond_expr: $4 ){
                    count_of_qualifiying_expressions.emplace_back(
                        driver.tm->mkTerm(
                            cvc5::Kind::ITE,
                            {cond_expr,
                             driver.tm->mkInteger(1),
                             driver.tm->mkInteger(0)}
                        )
                    );
                }

                $$ = driver.tm->mkTerm(
                    cvc5::Kind::GT,
                    { driver.tm->mkInteger(num_of_qualifications_needed),
                      driver.tm->mkTerm(
                        cvc5::Kind::ADD,
                        count_of_qualifiying_expressions
                      )
                    }
                );
            };
            break;
            case quant::at_most :{
                std::vector<cvc5::Term> count_of_qualifiying_expressions;

                for ( const auto& cond_expr: $4 ){
                    count_of_qualifiying_expressions.emplace_back(
                        driver.tm->mkTerm(
                            cvc5::Kind::ITE,
                            {cond_expr,
                             driver.tm->mkInteger(1),
                             driver.tm->mkInteger(0)}
                        )
                    );
                }

                $$ = driver.tm->mkTerm(
                    cvc5::Kind::LT,
                    { driver.tm->mkInteger(num_of_qualifications_needed),
                      driver.tm->mkTerm(
                        cvc5::Kind::ADD,
                        count_of_qualifiying_expressions
                      )
                    }
                );

            };
            break;
            case quant::always :{
                $$ = driver.tm->mkTrue();
            };
            break;

            default:  break;
        }

    }
}

zow_quantifier : %empty {
    if (driver.p == phase3){
      $$ = std::nullopt;
    }
  };
  | quantifier {
    if (driver.p == phase3){
      $$ = $1;
    }
  };
zom_determining_exprs : %empty {
    if ( driver.p == phase3 ){
        std::vector<cvc5::Term> t;
        $$ = t;
    }
  };
  | zom_determining_exprs determining_exprs {
    if ( driver.p == phase3 ){
      $$ = $1;
      $$.emplace_back($2);
    }
  }
determining_exprs : "-" expr "." {
    if (driver.p == phase3){
      $$ = $2;
    }
  }

then_block : "then" ":" wom_stmts {
    if (driver.p == phase3){

        std::vector<cvc5::Term> then_funcs;

        // f(member) -> member
        auto member_to_member = driver.tm->mkFunctionSort(
            { driver.members_const.getSort() },
            driver.members_const.getSort()
        );

        // g(  f(member) -> member   ) -> bool
        auto member_to_bool = driver.tm->mkFunctionSort(
            { member_to_member },
            driver.tm->getBooleanSort()
        );

        for ( const auto & stmt : $3 ){

            auto func_mem_to_mem = driver.tm->mkConst(
                member_to_member,
                ( "f_" + std::to_string(driver.stmt_count) )
            );
            driver.stmt_count += 1;


            auto apply_stmt = driver.tm->mkTerm(
                cvc5::Kind::APPLY_UF,
                { func_mem_to_mem , driver.members_var }
            );

            driver.slv->assertFormula(
                driver.tm->mkTerm(
                    cvc5::Kind::EQUAL,
                    { apply_stmt , stmt }
                )
            );

            auto func_mem_to_bool = driver.tm->mkConst(
                member_to_bool,
                ( "f_" + std::to_string(driver.stmt_count) )
            );
            driver.stmt_count += 1;

            auto return_bool = driver.tm->mkTerm(
                cvc5::Kind::APPLY_UF,
                { func_mem_to_bool , func_mem_to_mem }
            );

            driver.slv->assertFormula(
                driver.tm->mkTerm(
                    cvc5::Kind::EQUAL,
                    { return_bool , driver.tm->mkTrue() }
                )
            );

            then_funcs.emplace_back(return_bool);
        }

        $$ = then_funcs;

    }
}


wom_stmts : wom_stmts stmt {
    if (driver.p == phase3) {
      $$ = $1;
      $$.emplace_back($2);
    }
  };
  | stmt {
    if (driver.p == phase3) {
      std::vector<cvc5::Term> t;
      t.emplace_back($1);
      $$ = t;
    }
  };


quantifier
  : "any" {
    if (driver.p == phase3) {
      $$ = std::make_pair(quant::any,0);
    }
  };
  | "all" {
    if (driver.p == phase3) {
      $$ = std::make_pair(quant::all,0);
    }
  };
  | "at" "most" INT {
    if (driver.p == phase3) {
      $$ = std::make_pair(quant::at_most,$3);
    }
  };
  | "at" "least" INT {
    if (driver.p == phase3) {
      $$ = std::make_pair(quant::at_least,$3);
    }
  };
  | "always" {
    if (driver.p == phase3) {
      $$ = std::make_pair(quant::always,0);
    }
  };
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

assignment : lhs_name_sel "'" ":=" expr {
    if (driver.p == phase3) {

        auto updater_term = $1;

        auto expression_to_apply = $4;

        $$ = driver.tm->mkTerm(
            cvc5::Kind::APPLY_UPDATER,
            {updater_term, driver.members_var, expression_to_apply}
        );

    }
}

expr  : equality
      | expr "and" equality {
        if ( driver.p == phase3 ) {
          $$ = driver.tm->mkTerm(
            cvc5::Kind::AND,
            {$1,$3}
          );
        }
      }
      | expr "or" equality{
        if ( driver.p == phase3 ) {
          $$ = driver.tm->mkTerm(
            cvc5::Kind::OR,
            {$1,$3}
          );
        }
      }
      | expr "or-rather" equality{
        if ( driver.p == phase3 ) {
          $$ = driver.tm->mkTerm(
            cvc5::Kind::XOR,
            {$1,$3}
          );
        }
      }
      | "not" expr {
        if ( driver.p == phase3 ) {
          $$ = driver.tm->mkTerm(
            cvc5::Kind::NOT,
            {$2}
          );
        }
      }

equality  : set_opers
          | equality "equals" set_opers {
            if ( driver.p == phase3 ) {
              $$ = driver.tm->mkTerm(
                cvc5::Kind::EQUAL,
                {$1,$3}
              );
            }
          }
          | equality "not-equals" set_opers {
            if ( driver.p == phase3 ) {
              auto equal = driver.tm->mkTerm(
                cvc5::Kind::EQUAL,
                {$1,$3}
              );
              $$ = driver.tm->mkTerm(
                cvc5::Kind::NOT,
                {equal}
              );
            }
          }

set_opers  : membership
           | set_opers "unions" membership {
              if ( driver.p == phase3 ) {
                $$ = driver.tm->mkTerm(
                  cvc5::Kind::SET_UNION,
                  {$1,$3}
                );
              }
            }
           | set_opers "intersects" membership {
              if ( driver.p == phase3 ) {
                $$ = driver.tm->mkTerm(
                  cvc5::Kind::SET_INTER,
                  {$1,$3}
                );
              }
            }
           | set_opers "differences" membership {
              if ( driver.p == phase3 ) {
                $$ = driver.tm->mkTerm(
                  cvc5::Kind::SET_MINUS,
                  {$1,$3}
                );
              }
            }
           | set_opers "is-in" membership {
              if ( driver.p == phase3 ) {
                $$ = driver.tm->mkTerm(
                  cvc5::Kind::SET_MEMBER,
                  {$1,$3}
                );
              }
            }
           | set_opers "is-subset" membership {
              if ( driver.p == phase3 ) {
                $$ = driver.tm->mkTerm(
                  cvc5::Kind::SET_SUBSET,
                  {$1,$3}
                );
              }
            }
           | "compliments" set_opers {
              if ( driver.p == phase3 ) {
                $$ = driver.tm->mkTerm(
                  cvc5::Kind::SET_COMPLEMENT,
                  {$2}
                );
              }
            }

membership  : arithmatic
            | membership "is-greater-than" zow_or_equals arithmatic {
              if ( driver.p == phase3 ) {

                bool has_or_equals = $3.value_or(false);
                cvc5::Kind gtoe = has_or_equals ? cvc5::Kind::GEQ : cvc5::Kind::GT;

                $$ = driver.tm->mkTerm(
                  gtoe, {$1,$4}
                );
              }
            }
            | membership "is-less-than" zow_or_equals arithmatic {
              if ( driver.p == phase3 ) {

                bool has_or_equals = $3.value_or(false);
                cvc5::Kind ltoe = has_or_equals ? cvc5::Kind::LEQ : cvc5::Kind::LT;

                $$ = driver.tm->mkTerm(
                  ltoe, {$1,$4}
                );
              }
            }
            | membership zow_is "between" range {
              if ( driver.p == phase3 ) {

                auto range = $4;
                cvc5::Kind lower_kind = std::get<0>(range);
                cvc5::Kind upper_kind = std::get<1>(range);
                cvc5::Term lower_term = std::get<2>(range);
                cvc5::Term upper_term = std::get<3>(range);

                auto lower_range = driver.tm->mkTerm(
                  lower_kind, {$1,lower_term}
                );

                auto upper_range = driver.tm->mkTerm(
                  upper_kind, {$1,upper_term}
                );

                $$ = driver.tm->mkTerm(
                  cvc5::Kind::AND,
                  { lower_range, upper_range }
                );

              }
            }

zow_is : %empty  | "is"

zow_or_equals : %empty {
  if (driver.p == phase3) {
    $$ = std::nullopt;
  }
}; | "or-equals" {
  if (driver.p == phase3) {
    $$ = true;
  }
};


range : arithmatic ".." arithmatic {
       if (driver.p == phase3) {
        //defualt is inclusive
        $$ = std::make_tuple(
          cvc5::Kind::GEQ,cvc5::Kind::LEQ,
          $1,$3
        );
       }
      }
      | "(" arithmatic ".." arithmatic ")" {
       if (driver.p == phase3) {
        $$ = std::make_tuple(
          cvc5::Kind::GT,cvc5::Kind::LT,
          $2,$4
        );
       }
      }
      | "(" arithmatic ".." arithmatic "]" {
       if (driver.p == phase3) {
        $$ = std::make_tuple(
          cvc5::Kind::GT,cvc5::Kind::LEQ,
          $2,$4
        );
       }
      }
      | "[" arithmatic ".." arithmatic ")" {
       if (driver.p == phase3) {
        $$ = std::make_tuple(
          cvc5::Kind::GEQ,cvc5::Kind::LT,
          $2,$4
        );
       }
      }
      | "[" arithmatic ".." arithmatic "]" {
       if (driver.p == phase3) {
        $$ = std::make_tuple(
          cvc5::Kind::GEQ,cvc5::Kind::LEQ,
          $2,$4
        );
       }
      }

arithmatic  : term
            | arithmatic "+" term {
              if (driver.p == phase3) {
                $$ = driver.tm->mkTerm(
                  cvc5::Kind::ADD,
                  {$1,$3}
                );
              }
            }
            | arithmatic "-" term {
              if (driver.p == phase3) {
                $$ = driver.tm->mkTerm(
                  cvc5::Kind::SUB,
                  {$1,$3}
                );
              }
            }
            | arithmatic "*" term {
              if (driver.p == phase3) {
                $$ = driver.tm->mkTerm(
                  cvc5::Kind::MULT,
                  {$1,$3}
                );
              }
            }
            | arithmatic "/" term {
              if (driver.p == phase3) {
                $$ = driver.tm->mkTerm(
                  cvc5::Kind::INTS_DIVISION,
                  {$1,$3}
                );
              }
            }


rhs_name_sel  : WORD {

  if(driver.p == phase2 || driver.p == phase3) {

    // (note 1)
    // we initially have to use the const to perform selection
    // before we initalize, in all other phases we will use the
    // initialized members_var
    cvc5::Term members;
    if (driver.p == phase2) {
        members = driver.members_const;
    }
    else if (driver.p == phase3) {
        members = driver.members_var;
    }

    std::string member_name{ $1 };

    auto mem_sel = members
                    .getSort()
                    .getDatatype()[acc::fields]
                    .getSelector(member_name)
                    .getTerm();


    auto field_term = driver.tm->mkTerm(
        cvc5::Kind::APPLY_SELECTOR,
        { mem_sel , members }
    );

    $$ = field_term;
  }

};
  | WORD wom_sel {

    if(driver.p == phase2 || driver.p == phase3) {

        // see note 1
        cvc5::Term members;
        if (driver.p == phase2) {
            members = driver.members_const;
        }
        else if (driver.p == phase3) {
            members = driver.members_var;
        }

      std::string member_name = std::string($1);
      std::vector<std::string> selectors_vec { $2 };
      auto mem_sel = members
                        .getSort()
                        .getDatatype()[acc::fields]
                        .getSelector(member_name)
                        .getTerm();

      auto field_term = driver.tm->mkTerm(
          cvc5::Kind::APPLY_SELECTOR,
          { mem_sel, members }
      );

      auto curr_sel    { mem_sel };    //cvc5 selector
      auto temp_term   { field_term }; //cvc5 term
      for ( std::size_t i = 1; i < selectors_vec.size() ; i+= 1 ) {

        std::string next_sel_name = selectors_vec[i] ;

        curr_sel = curr_sel
                    .getSort()
                    .getDatatype()[acc::fields]
                    .getSelector(next_sel_name)
                    .getTerm();

        temp_term = driver.tm->mkTerm(
            cvc5::Kind::APPLY_SELECTOR,
            { curr_sel, temp_term }
        );
      }

      // vec is never empty via grammar rules
      std::string field_to_sel { selectors_vec.back() };

      curr_sel = temp_term
                    .getSort()
                    .getDatatype()[acc::fields]
                    .getSelector(field_to_sel)
                    .getTerm();

      field_term = driver.tm->mkTerm(
          cvc5::Kind::APPLY_SELECTOR,
          { curr_sel, temp_term }
      );

      $$ = field_term;

    };

};



lhs_name_sel  : WORD {

  if(driver.p == phase3) {

    std::string member_name{ $1 };

    auto mem_sel_updater = driver.members_const
                          .getSort()
                          .getDatatype()[acc::fields]
                          .getSelector(member_name)
                          .getUpdaterTerm();

    $$ = mem_sel_updater;
  }

};
  | WORD wom_sel {

    if(driver.p == phase2 || driver.p == phase3) {

        // see note 1
        cvc5::Term members;
        if (driver.p == phase2) {
            members = driver.members_const;
        }
        else if (driver.p == phase3) {
            members = driver.members_var;
        }

      std::string member_name = std::string($1);
      std::vector<std::string> selectors_vec { $2 };
      auto mem_sel = members
                        .getSort()
                        .getDatatype()[acc::fields]
                        .getSelector(member_name)
                        .getTerm();

      auto field_term = driver.tm->mkTerm(
          cvc5::Kind::APPLY_SELECTOR,
          { mem_sel, members }
      );

      auto curr_sel    { mem_sel };    //cvc5 selector
      auto temp_term   { field_term }; //cvc5 term
      for ( std::size_t i = 1; i < selectors_vec.size() ; i+= 1 ) {

        std::string next_sel_name = selectors_vec[i] ;

        curr_sel = curr_sel
                    .getSort()
                    .getDatatype()[acc::fields]
                    .getSelector(next_sel_name)
                    .getTerm();

        temp_term = driver.tm->mkTerm(
            cvc5::Kind::APPLY_SELECTOR,
            { curr_sel, temp_term }
        );
      }

      // vec is never empty via grammar rules
      std::string field_to_sel { selectors_vec.back() };

      auto curr_sel_updater = temp_term
                              .getSort()
                              .getDatatype()[acc::fields]
                              .getSelector(field_to_sel)
                              .getUpdaterTerm();


      $$ = curr_sel_updater;

    };

};




wom_sel : wom_sel "->" WORD {
    if(driver.p == phase2 || driver.p == phase3) {
      $$ = $1;
      $$.emplace_back($3);
    }
  }
  | "->" WORD {
    if(driver.p == phase2 || driver.p == phase3) {
      std::vector<std::string> t;
      t.emplace_back($2);
      $$ = t;
    }
  }

term  : atom { if (driver.p == phase3) $$=$1; }
      | "(" expr ")" { if (driver.p == phase3) $$=$2; }

structure : atom
/*TODO: struct map*/
/*
      | "{" wom_structure_row "}" {
          if(driver.p == phase2) {
          }
};
wom_structure_row : wom_structure_row "," structure_row | structure_row
structure_row : WORD ":" structure
*/

atom : INT {
  if(driver.p == phase2 || driver.p == phase3) {
    $$ = driver.tm->mkInteger($1);
  }
}; | FLOAT {
  //TODO: float -> bitvector nonsense
};
   | rhs_name_sel
   | tuple_val {}
   | FALSE
   | TRUE
   | enum_val {}

enum_val : rhs_name_sel "<" WORD ">"
tuple_val : "(" wom_atom  ")"
wom_atom : wom_atom "," atom | atom


//TODO: ensure members can only be declared once

//TODO: -Wcounterexamples

//TODO: refactor $$ = $1, to more effecient move or insert

%%

void yy::calcxx_parser::error(const location_type &l, const std::string &m)
{
  driver.error(l, m);
}
