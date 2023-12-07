 /*-----------------------------------------------------------------------------
                                 Operadores
-----------------------------------------------------------------------------*/

:- op(10,xfx,':').
:- op(15,xfx,'=>').
:- op(20,xfx,'=>>').

/*----------------------------------
Abrir y guardar base de conocimiento
----------------------------------*/

open_kb(Route,KB):-
	open(Route,read,Stream),
	readclauses(Stream,X),
	close(Stream),
	atom_to_term(X,KB).
save_kb(Route,KB):-
	open(Route,write,Stream),
	writeq(Stream,KB),
	close(Stream).

readclauses(InStream,W) :-
        get0(InStream,Char),
        checkCharAndReadRest(Char,Chars,InStream),
	atom_chars(W,Chars).

checkCharAndReadRest(-1,[],_) :- !.  % End of Stream
checkCharAndReadRest(end_of_file,[],_) :- !.

checkCharAndReadRest(Char,[Char|Chars],InStream) :-
        get0(InStream,NextChar),
        checkCharAndReadRest(NextChar,Chars,InStream).

%compile an atom string of characters as a prolog term
atom_to_term(ATOM, TERM) :-
	atom(ATOM),
	atom_to_chars(ATOM,STR),
	atom_to_chars('.',PTO),
	append(STR,PTO,STR_PTO),
	read_from_chars(STR_PTO,TERM).
/*-----------------------------------------------------------------------------
                             Atributos
-----------------------------------------------------------------------------*/
%atributo(V,Kb,X) - Determina el valor de un atributo
%V: Propiedad a buscar
%Kb: Lista con el identificador, propiedades y relaciones de un objeto
%X: Valor de la propiedad
atributo(V,[H|T],X):-
    H = V=>X;
    atributo(V,T,X).

%atributos(V,Kb,X) - Determina todos los valores de una lista de atributos
%                    (Por ejemplo, encontrar todos los id de la lista)
%V: Propiedad a buscar
%Kb: Lista de todos los objetos de una clase
%X: Valor de la propiedad
atributos(_,[],[]):-!.
atributos(V,[H|T],[X|TS]):-
    atributo(V,H,U),
    X = U,
    atributos(V,T,TS).

%propiedad(Kb,Propiedad) - Regresa una lista con las propiedades procesadas
%Kb: Lista con las propiedades
%Propiedad: Lista con las propiedades procesadas
propiedad([],[]).
propiedad([H|T],[Propiedad|TS]):-
    pro(H,Propiedad),
    propiedad(T,TS).

/*-----------------------------------------------------------------------------
                             Manejo de listas
-----------------------------------------------------------------------------*/

%Regresa el mismo atomo junto con su afirmación o negación
valor_bool(X,X:'no se').
valor_bool0(X,X:no).
valor_bool1(X,X:si).

%Busca la existencia de un átomo en una lista
existe(_,[]):-fail.
existe(X,[H|T]):-
    X = H;
    existe(X,T).

%existe_p_r - Busca la existencia de una propiedad o relación
existe_p_r(_,[],_):-fail.
existe_p_r(X,[H|T],V):-
    H = X:V;
    H = (X=>U):W,
    V = U:W;
    existe_p_r(X,T,V).

%Invierte una lista
invertir([],[]).
invertir([H|T],X) :-
    invertir(T,Y),append(Y,[H],X).

%
eliminar(_,[],[]).
eliminar(H,[H|T],X) :-
    eliminar(H,T,X).
eliminar(H,[U|V],[U|X]) :-
    eliminar(H,V,X).

%eliminar_atomo(Atomo,Kb,X) - elimina un atomo de una lista, pueden ser
%                             propiedades o relaciones, de acuerdo con
%                             defaults y excepciones.
%Atomo: Átomo a evaluar
%Kb: Lista con propiedades o relaciones
%X: Lista con las propiedades o relaciones  considerando defaults y excepciones
eliminar_atomo(_,[],[]).
eliminar_atomo(Atomo,[H|T],X):-
    Atomo = U:_,
    H = U:_,
    eliminar_atomo(Atomo,T,X).
eliminar_atomo(Atomo,[H|T],X):-
    H = _=>>_,
    eliminar_atomo(Atomo,T,X).
eliminar_atomo(Atomo,[H|T],X):-
    Atomo = U=>_,
    H = U=>_,
    eliminar_atomo(Atomo,T,X).
eliminar_atomo(Atomo,[H|T],X):-
    Atomo = (U=>_):_,
    H = (U=>_):_,
    eliminar_atomo(Atomo,T,X).
eliminar_atomo(Atomo,[H|T],[H|X]):-
    eliminar_atomo(Atomo,T,X).

%limpiar_propiedades(X,Y) - Limpia una lista de propiedades o relaciones para
%                           considerar defaults, excepciones y especificidad
%X: Lista con propiedades o relaciones
%Y: Lista limpia con propiedades o relaciones
limpiar_propiedades([],[]).
limpiar_propiedades([H|T],[H|L]):-
    eliminar_atomo(H,T,Lista),
    limpiar_propiedades(Lista,L),!.

%anonimo(KB,KB2) - Renombra los objetos anónimos de una KB a un número
%                  aleatorio
%KB: Base de conocimiento
%KB2: Base de conocimiento sin objetos anónimos '-'
anonimo(dummy,[H1|T],[id=>H2|T]):-
    H1 = id=>'-',
    random(H2),!.
anonimo(dummy,[H1|T],[H1|T]):-
    H1 \= id=>'-'.
anonimo([],[]).
anonimo([H1|T1],[H2|T2]):-
    anonimo(dummy,H1,H2),
    anonimo(T1,T2).
anonimos([],[]).
anonimos([class(Clase,Madre,Propiedades,Relaciones,Objetos)|T1],[class(Clase,Madre,Propiedades,Relaciones,Objetos2)|T2]):-
    anonimo(Objetos,Objetos2),
    anonimos(T1,T2).

%anonimo2(KB,KB2) - Restaura los objetos anónimos, de número aleatorio a '-'
%KB: Base de conocimiento
%KB2: Base de conocimiento con objetos anónimos '-'
anonimo2(dummy,[id=>H1|T],[id=>H2|T]):-
    number(H1),
    H1 < 1,
    H2 = '-',!.
anonimo2(dummy,[H1|T],[H1|T]):-
    number(H1),
    H1 > 1.
anonimo2(dummy,[H1|T],[H1|T]):-
    not(number(H1)).
anonimo2([],[]).
anonimo2([H1|T1],[H2|T2]):-
    anonimo2(dummy,H1,H2),
    anonimo2(T1,T2).
anonimos2([],[]).
anonimos2([class(Clase,Madre,Propiedades,Relaciones,Objetos)|T1],[class(Clase,Madre,Propiedades,Relaciones,Objetos2)|T2]):-
    anonimo2(Objetos,Objetos2),
    anonimos2(T1,T2).

%objetos_anonimos(Objetos,Anonimos) - Regresa una lista con los objetos
%                                     anónimos de una lista de objetos
%Objetos: Lista con objetos a analizar
%Anonimos: Lista con los objetos anónimos de número aleatorio
objetos_anonimos([],[]).
objetos_anonimos([H1|T1],[H1|T2]):-
    number(H1),
    H1 < 1,
    objetos_anonimos(T1,T2).
objetos_anonimos([H1|T1],T2):-
    not(number(H1)),
    objetos_anonimos(T1,T2).

/*-----------------------------------------------------------------------------
                              Clases
-----------------------------------------------------------------------------*/
%madre(Clase,Kb,Madre) - Determina la madre de una clase
%Clase: Clase de interés
%Kb: Base de conocimiento
%Madre: Madre de la clase de interés
madre(_,[],_).
madre(Y,[class(Y,X,_,_,_)|_],X):-!.
madre(Clase,[_|T],Madre):-
    madre(Clase,T,Madre).

%hijos(Madre,Kb,Hijo) - Determina los hijos de una clase
%Madre: Clase de interés
%Kb: Base de conocimiento
%Hijo: Lista con los hijos de la clase de interés
hijos(_,[],[]).
hijos(Y,[class(X,Y,_,_,_)|T],[X|TS]):-
    hijos(Y,T,TS),!.
hijos(Madre,[_|T],Hijo):-
    hijos(Madre,T,Hijo).

%ext_kb(Kb,Clases) - Regresa todas las clases de la base de conocimiento
%Kb: Base de conocimiento
%Clases: Todas las clases de la base de conocimiento
ext_kb([],[]).
ext_kb([class(X,_,_,_,_)|T],[X|L]):-
    ext_kb(T,L).

%ramas(Clase,Kb,Rama) - Regresa en forma de lista la rama de una clase
%Clase: Clase de interés
%Kb, Base de conocimiento
%Rama: Lista con la rama de la clase de interés
ramas(top,[_|_],[]):-!.
ramas(Clase,[H|T],[Madre|TS]):-
    madre(Clase,[H|T],Madre),
    ramas(Madre,[H|T],TS).

%ext_clase(Clase,Kb,Objetos) - Determina los objetos de una clase
%Clase: Clase de interés
%Kb: Base de conocimiento
%Objetos: Variable de salida
ext_clase(_,[],[]):-fail.
ext_clase(Y,[class(Y,_,_,_,[H|T])|_],X):-
    atributos(id,[H|T],X),!.
ext_clase(Clase,[_|T],Objetos):-
    ext_clase(Clase,T,Objetos).

%objeto_clase(Objeto,Clases,Kb,Clase) - Determina la clase a la que pertenece un objeto
%Objeto: Objeto de interés
%Clases: Todas las clases de la base de conocimiento
%Kb: Base de conocimiento
%Clase: Clase a la que pertenece el objeto
objeto_clase(_,[],[],_).
objeto_clase(Objeto,[Cla|_],[H|T],Cla):-
    ext_clase(Cla,[H|T],Objetos),
    existe(Objeto,Objetos).
objeto_clase(Objeto,[_|Ses],[H|T],Cla):-
    objeto_clase(Objeto,Ses,[H|T],Cla).

%pro(Kb,Propiedad) - Procesa cada elemento de una lista de propiedades
%Kb: Lista que contiene la propiedad y su preferencia
%Propiedad: Propiedad procesada (junto con su identificador de existencia
%           o su valor).
pro([H|_],Propiedad):-
    not(X) = H,
    _=>>_ \= H,
    H \= _=>_,
    valor_bool0(X,Propiedad);
    H \= _=>>_,
    not(_) \= H,
    H \= _=>_,
    valor_bool1(H,Propiedad);
    H = _=>_,
    H \= _=>'-',
    valor_bool1(H,Propiedad);
    H = X=>'-',
    valor_bool(X,Propiedad);
    H = _=>>_,
    Propiedad = H.

%rel(Kb,Relacion) - Procesa cada elemento de una lista de relaciones
%Kb: Lista que contiene la relacion y su preferencia
%Relacion: Relacion procesada (junto con su identificador de existencia
%          o su valor).
rel([H|_],Relacion):-
    not(X=>'-') = H,
    Y = X=>'no sé',
    valor_bool0(Y,Relacion),!;
    not(X) = H,
    valor_bool0(X,Relacion),!;
    X=>'-' = H,
    Y = X=>'no sé',
    valor_bool1(Y,Relacion),!;
    X = H,
    valor_bool1(X,Relacion),!.

%buscaro(X,ID,Kb,Y) - Regresa la lista de propiedades y relaciones de un objeto
%                     dado su identificador
%X: Objeto de interés
%ID: identificador (id)
%Kb: Lista de todos los objetos de una clase
%Y: Lista con el identificador, propiedades y relaciones del objeto
buscaro(_,_,[],[]).
buscaro(X,ID,[H|T],Y):-
    buscar(X,ID,H,Y);
    buscaro(X,ID,T,Y).

%pro_ob(Clase,Objeto,Kb,Lobjeto) - Regresa la lista de propiedades y relaciones
%                                  de un objeto dado su identificador.
%Clase: Clase a la que pertenece el objeto
%Objeto: Objeto de interés
%Kb: Base de conocimiento
%Lobjeto: Lista con el identificador, propiedades y relaciones del objeto
pro_ob(_,_,[],[]).
pro_ob(Clase,Objeto,[class(Clase,_,_,_,[H|T])|_],Lobjeto):-
    buscaro(Objeto,id,[H|T],Lobjeto).
pro_ob(Clase,Objeto,[_|T],Lobjeto):-
    pro_ob(Clase,Objeto,T,Lobjeto).

%propiedad(Kb,Propiedad) - Regresa una lista con las propiedades procesadas
%Kb: Lista con las propiedades
%Propiedad: Lista con las propiedades procesadas
propiedad([],[]).
propiedad([H|T],[Propiedad|TS]):-
    pro(H,Propiedad),
    propiedad(T,TS).

%relacion(Kb,Relacion) - Regresa una lista con las relaciones procesadas
%Kb: Lista con las propiedades
%Relacion: Lista con las relaciones procesadas
relacion([],[]).
relacion([H|T],[Relacion|TS]):-
    rel(H,Relacion),
    relacion(T,TS).

/*----------------------------------------------------------------------------------
Solución del inciso e) de la pregunta 1:

propiedades_de_clase(Clase,Kb,Propiedad) - Regresa una lista con las propiedades
                                           procesadas de una clase
Clase: Clase de interés
Kb: Base de conocimiento
Propiedad: Lista con las propiedades procesadas
----------------------------------------------------------------------------------*/
propiedad_clase(_,[],[]):-!.
propiedad_clase(Clase,[class(Clase,_,[H|T],_,_)|_],Propiedad):-
    propiedad([H|T],Propiedad).
propiedad_clase(Clase,[_|T],Propiedad):-
    propiedad_clase(Clase,T,Propiedad).

propiedades_de_clase(Clase,Kb,Propiedad):-
    open_kb(Kb,KB),
    propiedad_clase(Clase,KB,Propiedad).
/*-----------------------------------------------------------------------------
                              Objetos
-----------------------------------------------------------------------------*/
%propiedad_objeto(Objeto,Kb,Propiedades) - Regresa una lista con las propiedades
%                                          procesadas de un objeto
%Objeto: Objeto de interés
%Kb: Base de conocimiento
%Propiedades: Lista con las propiedades procesadas
propiedad_objeto(Objeto,[H|T],Propiedades):-
    ext_kb([H|T],Clases),
    objeto_clase(Objeto,Clases,[H|T],Clase),
    pro_ob(Clase,Objeto,[H|T],Lobjeto),
    Lobjeto = [_,P|_],
    propiedad(P,Propiedades).


/*----------------------------------------------------------------------------------
Solución del inciso e) de la pregunta 1:

propiedades_de_objeto(Objeto,Kb,Propiedades) - Regresa una lista con las
                                               propiedades definitivas de un
                                               objeto
Objeto: Objeto de interés
Kb: Base de conocimiento
Propiedades: Lista con las propiedades definitivas del objeto de interés
----------------------------------------------------------------------------------*/
propiedadesobjeto([],[_|_],[]).
propiedadesobjeto([H1|T1],KB,[H2|T2]):-
    propiedades_objeto(H1,KB,H2),
    propiedadesobjeto(T1,KB,T2).
propiedades_objeto(Objeto,[H|T],Propiedades):-
    pro_ob(Objeto,[H|T],Pro),
    limpiar_propiedades(Pro,Propiedades).
propiedades_de_objeto(Objeto,Kb,Propiedades):-
    Objeto \= '-',
    open_kb(Kb,KB),
    propiedades_objeto(Objeto,KB,Propiedades);
    Objeto = '-',
    open_kb(Kb,X),
    save_kb(Kb,KB),
    open_kb(Kb,KB),
    e_c(top,KB,Objetos),
    propiedadesobjeto(Objetos,KB,Propiedades),
    save_kb(Kb,Y).
/*----------------------------------------------------------------------------------
------------------------------------------------------------------------------------
----------------------------------------------------------------------------------*/



/*----------------------------------------------------------------------------------
Pregunta 1 inciso a):

class_extension(Clase,Kb,Objetos) ->Determina todos los objetos de una clase,
                                    incluyendo la herencia
Clase: Clase de interés
Kb: Base de conocimiento (archivo entre comillas)
Obj: Objetos de la clase de interés, incluyendo la herencia
----------------------------------------------------------------------------------*/
c_e(a,[],[_|_],[]).
c_e(a,[Hij|Os],[H|T],Objetos):-
    c_e(a,Os,[H|T],Objeto),
    c_e(Hij,[H|T],O),
    append(O,Objeto,Objetos),!.
c_e(_,[],[]).
c_e(Clase,[H|T],Objetos):-
    ext_clase(Clase,[H|T],Objetos);
    hijos(Clase,[H|T],Hijos),
    c_e(a,Hijos,[H|T],Objetos).
class_extension(Clase,Kb,Objetos):-
    open_kb(Kb,X),
    save_kb(Kb,KB),
    open_kb(Kb,KB),
    c_e(Clase,KB,Objetos),
    save_kb(Kb,Y).


/*----------------------------------------------------------------------------------
/
%ext_propiedad(Propiedad,Kb,Lobjetos,Objetos) - Regresa la lista de objetos que
%                                               tienen una propiedad dada
%Propiedad: Propiedad de interés
%Kb: Base de conocimiento
%Lobjetos: Lista de objetos para la búsqueda
%Objetos: Lista de objetos que tienen la propiedad de interés
ext_propiedad(_,[_|_],[],[]).
ext_propiedad(Propiedad,Kb,[Obj|Etos],[Obj:V|Eto]):-
    propiedades_objeto(Obj,Kb,Propiedades),
    existe_p_r(Propiedad,Propiedades,V),
    ext_propiedad(Propiedad,Kb,Etos,Eto).
ext_propiedad(Propiedad,Kb,[Obj|Etos],Objeto):-
    propiedades_objeto(Obj,Kb,Propiedades),
    not(existe_p_r(Propiedad,Propiedades,_)),
    ext_propiedad(Propiedad,Kb,Etos,Objeto).


/*----------------------------------------------------------------------------------
Solución del inciso b) de la pregunta 1:

property_extension(Propiedad,Kb,Objetos) -> Muestra todos los objetos que tiene
                                            una propiedad

- Propiedad: Propiedad de interés
           (propiedad y su valor - propiedad:si propiedad:no
                                   (propiedad=>valor):si (propiedad=>valor):no
            propiedad sin valor (con valor indistinto) - propiedad propiedad=>valor)

- Kb: Base de conocimiento (archivo entre comillas)
- Objetos: Objetos que tienen la propiedad de interés
----------------------------------------------------------------------------------*/
e_p(Propiedad,Kb,Objetos):-
    c_e(top,Kb,Ext),
    ext_propiedad(Propiedad,Kb,Ext,Objetos).
property_extension(Propiedad,Kb,Objetos):-
    open_kb(Kb,X),
    save_kb(Kb,KB),
    open_kb(Kb,KB),
    e_p(Propiedad,KB,Objetos),
    save_kb(Kb,Y).
/
----------------------------------------------------------------------------------*/
