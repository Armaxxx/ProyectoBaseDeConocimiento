ayuda:-
    nl,write("extension_clase(Clase,Kb,Objetos)"),nl,nl,
    tab(10),write("Determina todos los objetos de una clase, incluyendo la herencia"),nl,
    nl,write("extension_propiedad(Propiedad,Kb,Objetos)"),nl,nl,
    tab(10),write("Determina todos los objetos que tienen la propiedad de interés"),nl,
    nl,write("extension_relacion(Relacion,Kb,Objetos)"),nl,nl,
    tab(10),write("Determina todas los objetos que tienen la relación de interés"),nl,
    nl,write("clases_objeto(Objeto,Kb,Ramas)"),nl,nl,
    tab(10),write("Regresa una lista con todas las clases a la que pertenece un objeto"),nl,
    nl,write("propiedades_de_objeto(Objeto,Kb,Propiedades)"),nl,nl,
    tab(10),write("Regresa una lista con las propiedades definitivas de un objeto"),nl,
    nl,write("propiedades_de_clase(Clase,Kb,Propiedad)"),nl,nl,
    tab(10),write("Regresa una lista con las propiedades procesadas de una clase"),nl,
    nl,write("relaciones_de_objeto(Objeto,Kb,Relaciones)"),nl,nl,
    tab(10),write("Regresa una lista con las relaciones definitivas de un objeto"),nl,
    nl,write("relaciones_de_clase(Clase,Kb,Relacion)"),nl,nl,
    tab(10),write("Regresa una lista con las relaciones procesadas de una clase"),nl,
    nl,write("eliminar_clase(Clase,KB,NvoKB)"),nl,nl,
    tab(10),write("Elimina una clase dada"),nl,
    nl,write("eliminar_objeto(Objeto,KB,NvoKB)"),nl,nl,
    tab(10),write("Elimina una clase objeto determinado"),nl,
    nl,write("eliminar_propiedad_clase(Clase,Propiedad, KB, NvoKB)"),nl,nl,
    tab(10),write("Elimina una propiedad de una clase"),nl,
    nl,write("eliminar_propiedad_objeto(Objeto,Propiedad,KB,NvoKB)"),nl,nl,
    tab(10),write("Elimina una propiedad de un objeto"),nl,
    nl,write("eliminar_relacion_clase(Clase,Relacion,KB,NvoKB)"),nl,nl,
    tab(10),write("Elimina una relación de una clase"),nl, 
    nl,write("eliminar_relacion_objeto(Objeto,Relacion,OriginalKB,NvoKB)"),nl,nl,
    tab(10),write("Elimina una relación de un objeto"),nl,
    nl,write("modifica_valor_propiedad_de_clase(Clase,Propiedad,Valor,KB,NvoKB)"),nl,nl,
    tab(10),write("cambia el valor de una propiedad especifica de una clase"),nl,    
    nl,write("modifica_valor_propiedad_de_clase(Clase,Propiedad,Valor,KB,NvoKB)"),nl,nl,
    tab(10),write("cambia el valor de una propiedad especifica de un objeto"),nl,
    nl,write("modifica_clase(Clase,Cambio,KB,Kb_nueva,Salida)"),nl,nl,
    tab(10),write("cambia el nombre de una clase y considera los cambios con sus clases hijos (modifica el nombre de la clase madre tambien)"),nl,       
    nl,write("modifica_nom_objeto(NombreObjeto,NuevoNombre,Kb,Nueva_Kb)"),nl,nl,
    tab(10),write("cambia el nombre de un objeto y actualiza las relaciones que teniacon otros"),nl,             
    nl,write("modifica_relacion_de_clase(Clase,Relacion,Cambio,KB,Kb2)"),nl,nl,
    tab(10),write("cambia la Relacion (o relaciones) de una Clase por una nueva"),nl,       
    nl,write("modifica_relacion_de_objeto(Objeto,Relacion,Cambio,KB,Kb2)"),nl,nl,
    tab(10),write("cambia la relacion de un Objeto de interesreemplazando la(s) relacion(es) actuales "),nl.                         

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
                             Manejo de atributos
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

%buscar(X,ID,Kb,Y) - Regresa la lista de propiedades y relaciones de un objeto 
%                    dado su identificador
%X: Valor de la propiedad
%ID: Propiedad (hecho para que sea el identificador id)
%Kb: Lista con el identificador, propiedades y relaciones de un objeto
%Y: Lista con el identificador, propiedades y relaciones de un objeto
buscar(X,ID,[H|T],Y):-
    H = ID=>X,
    Y = [H|T].

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
                              Manejo de clases
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


/*----------------------------------------------------------------------------------
------------------------------------------------------------------------------------
----------------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------------
Solución del inciso f) de la pregunta 1:

relaciones_clase(Clase,Kb,Relacion) - Regresa una lista con las relaciones
                                      procesadas de una clase
Clase: Clase de interés
Kb: Base de conocimiento
Relacion: Lista con las relaciones procesadas
----------------------------------------------------------------------------------*/
relacion_clase(_,[],[]):-!.
relacion_clase(Clase,[class(Clase,_,_,[H|T],_)|_],Relacion):-
    relacion([H|T],Relacion).
relacion_clase(Clase,[_|T],Relacion):-
    relacion_clase(Clase,T,Relacion).
relaciones_de_clase(Clase,Kb,Relacion):-
    open_kb(Kb,KB),
    relacion_clase(Clase,KB,Relacion).
/*----------------------------------------------------------------------------------
------------------------------------------------------------------------------------
----------------------------------------------------------------------------------*/

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

%relacion_objeto(Objeto,Kb,Relaciones) - Regresa una lista con las relaciones
%                                        procesadas de un objeto
%Objeto: Objeto de interés
%Kb: Base de conocimiento
%Relaciones: Lista con las relaciones procesadas
relacion_objeto(Objeto,[H|T],Relaciones):-
    ext_kb([H|T],Clases),
    objeto_clase(Objeto,Clases,[H|T],Clase),
    pro_ob(Clase,Objeto,[H|T],Lobjeto),
    Lobjeto = [_,_,R|_],
    relacion(R,Relaciones).

/*----------------------------------------------------------------------------------
Solución del inciso d) de la pregunta 1:

clases_objeto(Objeto,Kb,Ramas) - Regresa una lista con todas las clases a la que
                                 pertenece un objeto
Objeto: Objeto de interés
Kb: Base de conocimiento
Ramas: Lista con las clases a las quepertenece un objeto
----------------------------------------------------------------------------------*/
ramas_objeto(Objeto,[H|T],[Clase|Rama]):-
    ext_kb([H|T],Clases),
    objeto_clase(Objeto,Clases,[H|T],Clase),
    ramas(Clase,[H|T],Rama).
%    invertir([Clase|Rama],Ramas).
clases_objeto(Objeto,Kb,Clases):-
    open_kb(Kb,KB),
    ramas_objeto(Objeto,KB,Clases).
/*----------------------------------------------------------------------------------
------------------------------------------------------------------------------------
----------------------------------------------------------------------------------*/

%propiedad_clases(Clases,Kb,Propiedades) - Regresa una lista con las propiedades de
%                                          un conjunto de clases en forma de lista
%Clases: Clases de interés en forma de lista
%Kb: Base de conocimiento
%Propiedades: Lista con las propiedades de las clases
propiedad_clases([],[_|_],[]).
propiedad_clases([Cla|Se],[H|T],Propiedades):-
    propiedad_clases(Se,[H|T],Propiedad),
    propiedad_clase(Cla,[H|T],P),
    append(P,Propiedad,Propiedades),!.

%relacion_clases(Clases,Kb,Relaciones) - Regresa una lista con las relaciones
%                                        de un conjunto de clases en forma de
%                                        lista
%Clases: Clases de interés en forma de lista
%Kb: Base de conocimiento
%Relaciones: Lista con las relaciones de las clases
relacion_clases([],[_|_],[]).
relacion_clases([Cla|Se],[H|T],Relaciones):-
    relacion_clases(Se,[H|T],Relacion),
    relacion_clase(Cla,[H|T],R),
    append(R,Relacion,Relaciones).

%pro_ob(Objeto.Kb,Propiedades) - Regresa una lista con las propiedades de un objeto
%                                y de las clases a las que pertenece
%Objeto: Objeto de interés
%Kb: Base de conocimiento
%Propiedades: Lista con todas las propiedades de un objeto
pro_ob(Objeto,[H|T],Propiedades):-
    ramas_objeto(Objeto,[H|T],Ramas),
    propiedad_clases(Ramas,[H|T],Propiedad),
    propiedad_objeto(Objeto,[H|T],P),
    append(P,Propiedad,Propiedades).

%rel_ob(Objeto.Kb,Relaciones) - Regresa una lista con las relaciones de un
%                               objeto y de las clases a las que pertenece
%Objeto: Objeto de interés
%Kb: Base de conocimiento
%Relaciones: Lista con todas las relaciones de un objeto
rel_ob(Objeto,[H|T],Relaciones):-
    ramas_objeto(Objeto,[H|T],Ramas),
    relacion_clases(Ramas,[H|T],Relacion),
    relacion_objeto(Objeto,[H|T],R),
    append(R,Relacion,Relaciones).

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
    anonimos(X,KB),
    save_kb(Kb,KB),
    open_kb(Kb,KB),
    e_c(top,KB,Objetos),
    objetos_anonimos(Objetos,Anonimos),
    propiedadesobjeto(Anonimos,KB,Propiedades),
    anonimos2(KB,Y),
    save_kb(Kb,Y).
/*----------------------------------------------------------------------------------
------------------------------------------------------------------------------------
----------------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------------
Solución del inciso f) de la pregunta 1:

relaciones_de_objeto(Objeto,Kb,Relaciones) -   Regresa una lista con las 
                                               relaciones definitivas de un 
                                               objeto
Objeto: Objeto de interés
Kb: Base de conocimiento
Relaciones: Lista con las relaciones definitivas del objeto de interés
----------------------------------------------------------------------------------*/
relacionesobjeto([],[_|_],[]).
relacionesobjeto([H1|T1],KB,[H2|T2]):-
    relaciones_objeto(H1,KB,H2),
    relacionesobjeto(T1,KB,T2).
relaciones_objeto(Objeto,[H|T],Relaciones):-
    rel_ob(Objeto,[H|T],Rel),
    limpiar_propiedades(Rel,Relaciones),!.
relaciones_de_objeto(Objeto,Kb,Relaciones):-
    Objeto \= '-',
    open_kb(Kb,KB),
    relaciones_objeto(Objeto,KB,Relaciones);
    Objeto = '-',
    open_kb(Kb,X),
    anonimos(X,KB),
    save_kb(Kb,KB),
    open_kb(Kb,KB),
    e_c(top,KB,Objetos),
    objetos_anonimos(Objetos,Anonimos),
    relacionesobjeto(Anonimos,KB,Relaciones),
    anonimos2(KB,Y),
    save_kb(Kb,Y).
/*----------------------------------------------------------------------------------
------------------------------------------------------------------------------------
----------------------------------------------------------------------------------*/

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

%ext_relacion(Relacion,Kb,Lobjetos,Objetos) -   Regresa la lista de objetos que
%                                               tienen una relacion dada
%Relacion: Relacion de interés
%Kb: Base de conocimiento
%Lobjetos: Lista de objetos para la búsqueda
%Objetos: Lista de objetos que tienen la relacion de interés
ext_relacion(_,[_|_],[],[]).
ext_relacion(Relacion,Kb,[Obj|Etos],[(Obj=>V)|Eto]):-
    relaciones_objeto(Obj,Kb,Relaciones),
    existe_p_r(Relacion,Relaciones,V),
    ext_relacion(Relacion,Kb,Etos,Eto).
ext_relacion(Relacion,Kb,[Obj|Etos],Objeto):-
    relaciones_objeto(Obj,Kb,Relaciones),
    not(existe_p_r(Relacion,Relaciones,_)),
    ext_relacion(Relacion,Kb,Etos,Objeto).

/*----------------------------------------------------------------------------------
Solución del inciso a) de la pregunta 1:

extension_clase(Clase,Kb,Objetos) - Determina todos los objetos de una clase,
                                    incluyendo la herencia
Clase: Clase de interés
Kb: Base de conocimiento (archivo entre comillas)
Objetos: Objetos de la clase de interés, incluyendo la herencia
----------------------------------------------------------------------------------*/
e_c(dummy,[],[_|_],[]).
e_c(dummy,[Hij|Os],[H|T],Objetos):-
    e_c(dummy,Os,[H|T],Objeto),
    e_c(Hij,[H|T],O),
    append(O,Objeto,Objetos),!.
e_c(_,[],[]).
e_c(Clase,[H|T],Objetos):-
    ext_clase(Clase,[H|T],Objetos);
    hijos(Clase,[H|T],Hijos),
    e_c(dummy,Hijos,[H|T],Objetos).
extension_clase(Clase,Kb,Objetos):-
    open_kb(Kb,X),
    anonimos(X,KB),
    save_kb(Kb,KB),
    open_kb(Kb,KB),
    e_c(Clase,KB,Objetos),
    anonimos2(KB,Y),
    save_kb(Kb,Y).
/*----------------------------------------------------------------------------------
------------------------------------------------------------------------------------
----------------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------------
Solución del inciso b) de la pregunta 1:

extension_propiedad(Propiedad,Kb,Objetos) - Determina todos los objetos que tienen
                                            la propiedad de interés
Propiedad: Propiedad de interés 
           (propiedad y su valor - propiedad:si propiedad:no 
                                   (propiedad=>valor):si (propiedad=>valor):no
            propiedad sin valor (con valor indistinto) - propiedad propiedad=>valor)
            
Kb: Base de conocimiento (archivo entre comillas)
Objetos: Objetos que tienen la propiedad de interés
----------------------------------------------------------------------------------*/
e_p(Propiedad,Kb,Objetos):-
    e_c(top,Kb,Ext),
    ext_propiedad(Propiedad,Kb,Ext,Objetos).
extension_propiedad(Propiedad,Kb,Objetos):-
    open_kb(Kb,X),
    anonimos(X,KB),
    save_kb(Kb,KB),
    open_kb(Kb,KB),
    e_p(Propiedad,KB,Objetos),
    anonimos2(KB,Y),
    save_kb(Kb,Y).
/*----------------------------------------------------------------------------------
------------------------------------------------------------------------------------
----------------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------------
Solución del inciso c) de la pregunta 1:

extension_relacion(Relacion,Kb,Objetos) - Determina todas los objetos que 
                                          tienen la relación de interés
Relacion: Relación de interés            
Kb: Base de conocimiento (archivo entre comillas)
Objetos: Objetos que tienen la relación de interés
----------------------------------------------------------------------------------*/
e_r(Relacion,Kb,Objetos):-
    e_c(top,Kb,Ext),
    ext_relacion(Relacion,Kb,Ext,Objetos).
extension_relacion(Relacion,Kb,Objetos):-
    open_kb(Kb,X),
    anonimos(X,KB),
    save_kb(Kb,KB),
    open_kb(Kb,KB),
    e_r(Relacion,KB,Objetos),
    anonimos2(KB,Y),
    save_kb(Kb,Y),!.
/*----------------------------------------------------------------------------------
------------------------------------------------------------------------------------
----------------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
                             Manejo de listas
-----------------------------------------------------------------------------*/

%Cambia todas las ocurrencias de un elemento X en una lista por un elemento y
%cambiaElemento(X,Y,InputList,OutputList).
%Ejemplo (p,b,[p,a,p,a,y,a],[p,b,p,b,y,b])

cambiaElemento(_,_,[],[]).

cambiaElemento(X,Y,[X|T],[Y|N]):-
    cambiaElemento(X,Y,T,N).

cambiaElemento(X,Y,[H|T],[H|N]):-
    cambiaElemento(X,Y,T,N).


%Verify if an element X is in a list 
%esElemento(X,List)
%Example (n,[b,a,n,a,n,a])

esElemento(X,[X|_]).
esElemento(X,[_|T]):-
    esElemento(X,T).





/*----------------------------------------------------------------------------------
Solución del inciso a) de la pregunta 2:

clase_nueva(NvaClase,Madre,NvoKB,KB) - Añade una clase nueva.

NvaClase: Clase nueva
Kb: Base de conocimiento original 
Madre: clase madre de la clase nueva 
NvoKB: Base de datos que incluye la clase nueva

nuevo_Objeto(NvoObjeto,Clase,OriginalKB,NvoKB) - Añade un objeto nuevo.

NvoObjeto: Objeto nuevo
Kb: Base de conocimiento original 
Clase: clase del nuevo objeto
NvoKB: Base de datos que incluye la clase nueva
----------------------------------------------------------------------------------*/

%Agregar una clase nueva
nva_Clase(NvaClase,Madre,KB,NvaKB):-
    append(KB,[class(NvaClase,Madre,[],[],[])],NvaKB).

%Agragar un objeto nuevo

nvo_Objeto(NvoObjeto,Clase,KB,NvoKB) :-
    cambiaElemento(class(Clase,Madre,Props,Rels,Objetos),class(Clase,Madre,Props,Rels,NvosObjs),KB,NvoKB),
    append(Objetos,[ id=>NvoObjeto,[],[] ],NvosObjs).

/*----------------------------------------------------------------------------------
Solución del inciso b) de la pregunta 2:

nva_Propiedad_Clase(Clase,NvaPropiedad,Valor,Peso,KB,NvoKB)- Añade una propiedad de clase nueva.
Clase: Clase de la propiedad
NvaPropiedad: Nombre de la propiedad nueva
Valor: Valor de la propiedad 
Peso: Peso de la propiedad
KB: Base de conocimiento original
NvoKB: Nueva base de conocimiento 

nva_Propiedad_Objeto(Objeto,NvaPropiedad,Valor,Peso,KB,NvoKB)- Añade una propiedad de objeto nuevo.
Objeto: Objeto de la propiedad
NvaPropiedad: Nombre de la propiedad nueva
Valor: Valor de la propiedad 
Peso: Peso de la propiedad
KB: Base de conocimiento original
NvoKB: Nueva base de conocimiento 

----------------------------------------------------------------------------------*/

%Agregar una propiedad de clase

nva_Propiedad_Clase(Clase,NvaPropiedad,Valor,Peso,KB,NvoKB) :-
    cambiaElemento(class(Clase,Madre,Props,Rels,Objetos),class(Clase,Madre,NvasProps,Rels,Objetos),KB,NvoKB),
    concatenar_propiedad(Props,NvaPropiedad,Valor,Peso,NvasProps).

concatenar_propiedad(Props,NvaPropiedad,[],Peso,NvasProps):-
    append(Props,[ NvaPropiedad,Peso ],NvasProps).

%not(gracioso) o gracioso
concatenar_propiedad(Props,NvaPropiedad,Valor,Peso,NvasProps):-
    append(Props,[ NvaPropiedad=>Valor,Peso ],NvasProps).

%Agregar una propiedad a un objeto 

nva_Propiedad_Objeto(Objeto,NvaPropiedad,Valor,Peso,KB,NvoKB) :-
    cambiaElemento(class(Clase,Madre,Props,Rels,Objetos),class(Clase,Madre,Props,Rels,NvosObjs),KB,NvoKB),
    esElemento([id=>Objeto,Propiedades,Relaciones],Objetos),
    cambiaElemento([id=>Objeto,Propiedades,Relaciones],[id=>Objeto,NvasProps,Relaciones],Objetos,NvosObjs),
    concatenar_propiedad(Propiedades,NvaPropiedad,Valor,Peso,NvasProps).

/*----------------------------------------------------------------------------------
Solución del inciso c) de la pregunta 2:

nva_Rel_Clase(Clase,NvaRel,OtraClase,Peso,KB,NvoKB) - Añade una relación de clase nueva.
Clase: Clase de la relación
NvaPropiedad: Nombre de la relaciónrelación nueva
OtraClase: Clase a la cual apunta de la relación 
Peso: Peso de la relación
KB: Base de conocimiento original
NvoKB: Nueva base de conocimiento 

nva_Rel_Objeto(Objeto,NvaPropiedad,Valor,Peso,KB,NvoKB)- Añade una relación de objeto nuevo.
Objeto: Objeto de la relación
NvaPropiedad: Nombre de la relación nueva
OtroObjeto: Objeto al cual apunta de la relación 
Peso: Peso de la relación
KB: Base de conocimiento original
NvoKB: Nueva base de conocimiento 

----------------------------------------------------------------------------------*/

%Agregar nueva relación de clase 

nva_Rel_Clase(Clase,NvaRel,OtraClase,Peso,KB,NvoKB) :-
    cambiaElemento(class(Clase,Madre,Props,Rels,Objetos),class(Clase,Madre,Props,NvaRels,Objetos),KB,NvoKB),
    concatenar_rel(Rels,NvaRel,OtraClase,Peso,NvaRels).

concatenar_rel(Rels,not(NvaRel),OtraClase,Peso,NvaRels):-
    append(Rels,[ not(NvaRel=>OtraClase),Peso ],NvaRels).

concatenar_rel(Rels,NvaRel,OtraClase,Peso,NvaRels):-
    append(Rels,[ NvaRel=>OtraClase,Peso ],NvaRels).


%Agregar nueva relación de objeto  

nva_Rel_Objeto(Objeto,NvaRel,OtroObjeto,Peso,KB,NvoKB) :-
    cambiaElemento(class(Class,Madre,Props,Rels,Objetos),class(Class,Madre,Props,Rels,NvoObjetos),KB,NvoKB),
    esElemento([id=>Objeto,Propiedades,Relaciones],Objetos),
    cambiaElemento([id=>Objeto,Propiedades,Relaciones],[id=>Objeto,Propiedades,NvaRelaciones],Objetos,NvoObjetos),
    concatenar_rel(Relaciones,NvaRel,OtroObjeto,Peso,NvaRelaciones).

/*----------------------------------------------------------------------------------
Solución del inciso a) de la pregunta 3:

eliminar_clase(Clase,KB,NvoKB) - Elimina una clase dada.
Clase: Clase de la base de datos
KB: Base de conocimiento original
NvoKB: Nueva base de conocimiento 

eliminar_objeto(Objeto,KB,NvoKB)  - Elimina una clase objeto determinado.
Objeto: Objeto de la clase
KB: Base de conocimiento original
NvoKB: Nueva base de conocimiento 

----------------------------------------------------------------------------------*/

cambiar_madre(_,_,[],[]).

cambiar_madre(Madre,NvaMadre,[class(Clase,Madre,Props,Relaciones,Objs)|T],[class(Clase,NvaMadre,Props,Relaciones,Objs)|T2]):-
    cambiar_madre(Madre,NvaMadre,T,T2).

cambiar_madre(Madre,NvaMadre,[H|T],[H|T2]):-
    cambiar_madre(Madre,NvaMadre,T,T2).

eliminar_clase(Clase,KB,NvoKB):-
    eliminar(class(Clase,Madre,_,_,_),KB,Aux1),
    cambiar_madre(Clase,Madre,Aux1,Aux2),
    eliminar_relaciones_con_objetos(Clase,Aux2,NvoKB).


eliminar_objeto(Objeto,KB,NvoKB):-
    cambiaElemento(class(Clase,Madre,Props,Relaciones,Objetos),class(Clase,Madre,Props,Relaciones,NvoObjetos),KB,Aux1),
    esElemento([id=>Objeto|Propiedades],Objetos),
    eliminar([id=>Objeto|Propiedades],Objetos,NvoObjetos),
    eliminar_relaciones_con_objetos(Objeto,Aux1,NvoKB).


eliminar_relaciones_con_objetos(_,[],[]).

eliminar_relaciones_con_objetos(Objeto,[class(C,M,P,R,O)|T],[class(C,M,P,NvoR,NvoO)|T2]):-
    cancelar_relacionces(Objeto,R,NvoR),
    eliminar_relaciones_auxiliar(Objeto,O,NvoO),
    eliminar_relaciones_con_objetos(Objeto,T,T2).

eliminar_relaciones_auxiliar(_,[],[]).

eliminar_relaciones_auxiliar(Objeto,[[id=>N,P,R]|T],[[id=>N,P,NvoR]|T2]):-
    cancelar_relacionces(Objeto,R,NvoR),
    eliminar_relaciones_auxiliar(Objeto,T,T2).

cancelar_relacionces(_,[],[]).

cancelar_relacionces(Objeto,[[_=>Objeto,_]|T],T2):-
    cancelar_relacionces(Objeto,T,T2).

cancelar_relacionces(Objeto,[[not(_=>Objeto),_]|T],T2):-
    cancelar_relacionces(Objeto,T,T2).

cancelar_relacionces(Objeto,[[V=>Lst,W]|T],T2):-
        is_list(Lst),
        eliminar(Objeto,Lst,NewLst),
        cancelar_relacionces(Objeto,T,Tmp),
        length(NewLst,Size),
        (Size==1-> [Head|_] = NewLst, T2 = [[V=>Head,W]|Tmp];
        (Size>1-> T2 = [[V=>NewLst,W]|Tmp];
         T2 = Tmp)
        ).
        

cancelar_relacionces(Objeto,[H|T],[H|T2]):-
    cancelar_relacionces(Objeto,T,T2).
 
/*----------------------------------------------------------------------------------
Solución del inciso b) de la pregunta 3:

eliminar_propiedad_clase(Clase,Propiedad, KB, NvoKB) - Elimina una propiedad de una clase.
Clase: Clase de la base de datos
Propiedad: Propiedad que se quiere eliminar
KB: Base de conocimiento original
NvoKB: Nueva base de conocimiento 

eliminar_propiedad_objeto(Objeto,Propiedad,KB,NvoKB)  - Elimina una propiedad de un objeto.
Objeto: Objeto de la clase
Propiedad: Propiedad que se quiere eliminar
KB: Base de conocimiento original
NvoKB: Nueva base de conocimiento 

----------------------------------------------------------------------------------*/

eliminar_elementos_con_propiedad(_,[],[]).

eliminar_elementos_con_propiedad(X,[[X=>_,_]|T],T2):-
    eliminar_elementos_con_propiedad(X,T,T2).

eliminar_elementos_con_propiedad(X,[H|T],[H|T2]):-
    eliminar_elementos_con_propiedad(X,T,T2).


eliminar_propiedad_clase(Clase,Propiedad, KB, NvoKB):-
    cambiaElemento(class(Clase,Madre,Propiedades,Relaciones,Objetos),class(Clase,Madre,NvoProps,Relaciones,Objetos),KB,NvoKB),
    eliminar_elementos_con_propiedad(Propiedad,Propiedades,Aux1),
    eliminar([not(Propiedad),_],Aux1,Aux2),
    eliminar([Propiedad,_],Aux2,NvoProps).

eliminar_propiedad_objeto(Objeto,Propiedad,KB,NvoKB) :-
    cambiaElemento(class(Clase,Madre,Props,Rels,Objetos),class(Clase,Madre,Props,Rels,NvoObjetos),KB,NvoKB),
    esElemento([id=>Objeto,Propiedades,Relaciones],Objetos),
    cambiaElemento([id=>Objeto,Propiedades,Relaciones],[id=>Objeto,NvoPropiedades,Relaciones],Objetos,NvoObjetos),
    eliminar_elementos_con_propiedad(Propiedad,Propiedades,Aux1),
    eliminar([not(Propiedad),_],Aux1,Aux2),
    eliminar([Propiedad,_],Aux2,NvoPropiedades).
/*----------------------------------------------------------------------------------
Solución del inciso c) de la pregunta 3:

eliminar_relacion_clase(Clase,Relacion,KB,NvoKB) - Elimina una relación de una clase.
Clase: Clase de la base de datos
Relacion: Relacion que se quiere eliminar
KB: Base de conocimiento original
NvoKB: Nueva base de conocimiento 

eliminar_relacion_objeto(Objeto,Relacion,KB,NvoKB)  - Elimina una relación de un objeto.
Objeto: Objeto de la clase
Relacion: Relacion que se quiere eliminar
KB: Base de conocimiento original
NvoKB: Nueva base de conocimiento 

----------------------------------------------------------------------------------*/

eliminar_elementos_con_propiedad_negada(_,[],[]).

eliminar_elementos_con_propiedad_negada(X,[[not(X=>_),_]|T],T2):-
    eliminar_elementos_con_propiedad_negada(X,T,T2).

eliminar_elementos_con_propiedad_negada(X,[H|T],[H|T2]):-
    eliminar_elementos_con_propiedad_negada(X,T,T2).


eliminar_relacion_clase(Clase,Relacion,KB,NvoKB):-
    cambiaElemento(class(Clase,Madre,Props,Relaciones,Objetos),class(Clase,Madre,Props,NvoRelaciones,Objetos),KB,NvoKB),
    eliminar_elementos_con_propiedad(Relacion,Relaciones,Aux1),
    eliminar_elementos_con_propiedad_negada(Relacion,Aux1,NvoRelaciones).

eliminar_relacion_objeto(Objeto,Relacion,KB,NvoKB):-
    cambiaElemento(class(Clase,Madre,Props,Rels,Objetos),class(Clase,Madre,Props,Rels,NvoObjetos),KB,NvoKB),
    esElemento([id=>Objeto,Properties,Relaciones],Objetos),
    cambiaElemento([id=>Objeto,Properties,Relaciones],[id=>Objeto,Properties,NvoRelaciones],Objetos,NvoObjetos),
    eliminar_elementos_con_propiedad(Relacion,Relaciones,Aux1),
    eliminar_elementos_con_propiedad_negada(Relacion,Aux1,NvoRelaciones).







/*--------------------------------------------------------------
Para la pregunta 4 a)
---------------------------------------------------------------*/

obtiene_datos(_,_,[],[]).
obtiene_datos(X,Y,[class(Z,M,P,R,I)|_],[class(Ys,Ms,P,R,I)]):-
    (X==Z->Ys=Y;Ys=Z),
    (X==M->Ms=Y;Ms=M).

modifica_c(_,_,[],[]).
modifica_c(Clase,Cambio,[Ba|Se],Nuevo_KB):-
    obtiene_datos(Clase,Cambio,[Ba|Se],Rs),modifica_c(Clase,Cambio,Se,Rss),
    append(Rs,Rss,Nuevo_KB),!.


/*-----------predicados para actualizar relaciones entre objetos-------------*/
corr(_,_,[],[]):-!.
corr(X,Y,[H|T],[Hs|Ts]):-
    (X==H->Hs=Y;Hs=H),corr(X,Y,T,Ts).
corr(X,Y,T,Z):-
    X==T->Z=Y;Z=T.

corrige(_,_,[],[]):-!.
corrige(X,Y,[[Rel=>[ObjH|ObjT],Peso]|T],[[Rel=>N,Peso]|Ts]):-
    corr(X,Y,[ObjH|ObjT],N),
    corrige(X,Y,T,Ts),!.  
corrige(X,Y,[[Rel=>Obj,Peso]|T],[[Rel=>N,Peso]|Ts]):-
    corr(X,Y,Obj,N),
    corrige(X,Y,T,Ts).  

corrige_r(_,_,[],[]):-!.
corrige_r(X,Y,[[In,Prop,Rel]|T],[[In,Prop,Rel2]|Ts]):-
    corrige(X,Y,Rel,Rel2),corrige_r(X,Y,T,Ts).


/*al modificar el nombre del objeto, corrige las relaciones 
    que tiene o tienen con el
*/
corrige_relacion(_,_,[],[]):-!.
corrige_relacion(Obj,Nom,[class(C,M,P,R,I)|Se],[class(C,M,P,R,Is)|Kb2T]):-
    corrige_r(Obj,Nom,I,Is),corrige_relacion(Obj,Nom,Se,Kb2T). 

/*-----predicados para modificar nombre del objeto--------------------------*/
cambia_nom(_,_,[],[]):-!.
cambia_nom(X,Y,[[id=>H|Ti]|T],[[Hs|Ti]|Ts]):-    
    (X==H->Hs = id=>Y;Hs=id=>H),
    cambia_nom(X,Y,T,Ts).

cambia_nom_o(_,_,[],[]):-!.
cambia_nom_o(_,_,class(C,M,P,R,[]),class(C,M,P,R,[])):-!.
cambia_nom_o(X,Y,class(C,M,P,R,I),class(C,M,P,R,Is)):-
    cambia_nom(X,Y,I,Is).

cambia_nombre_obj(_,_,[],[]):-!.
cambia_nombre_obj(NomObj,NuNom,[Ba|Se],[Kb2|Kb4]):-
    cambia_nom_o(NomObj,NuNom,Ba,Kb2),
    cambia_nombre_obj(NomObj,NuNom,Se,Kb4).

/*------------------------Inciso c)----------------------------------------------*/


modifica_relacion(_,_,[],[]):-!.
modifica_relacion(Relacion,Cambio,[[Relacion=>_,Peso]|T],[[Relacion=>Cambio,Peso]|T]):-!.
modifica_relacion(Relacion,Cambio,[[R=>V,P]|T],[[R=>V,P]|Ts]):-
    Relacion\==R,modifica_relacion(Relacion,Cambio,T,Ts).


modifica_relacion_de_c(_,_,_,[],[]):-!.
modifica_relacion_de_c(Clase,Relacion,Cambio,[class(Clase,M,P,R,I)|T],[class(Clase,M,P,Rs,I)|T]):-
    modifica_relacion(Relacion,Cambio,R,Rs),!.
modifica_relacion_de_c(Clase,Relacion,Cambio,[class(C,M,P,R,I)|T],[class(C,M,P,R,I)|Ts]):-
    Clase\==C,modifica_relacion_de_c(Clase,Relacion,Cambio,T,Ts),!.



modifica_rel_de_ob(_,_,_,[],[]):-!.
modifica_rel_de_ob(Ob,Rel,Cam,[[id=>Ob,PO,RO]|T],[[id=>Ob,PO,Rs]|T]):-
    modifica_relacion(Rel,Cam,RO,Rs).
modifica_rel_de_ob(Ob,Rel,Cam,[[id=>Otro,PO,RO]|T],[[id=>Otro,PO,RO]|Ts]):-
    Ob\==Otro,modifica_rel_de_ob(Ob,Rel,Cam,T,Ts).

modifica_relacion_de_o(_,_,_,[],[]):-!.
modifica_relacion_de_o(Objeto,Relacion,Cambio,[class(C,M,P,R,I)|T],[class(C,M,P,R,Is)|Ts]):-
    modifica_rel_de_ob(Objeto,Relacion,Cambio,I,Is),
    modifica_relacion_de_o(Objeto,Relacion,Cambio,T,Ts),!.

/*--------------------------------------------------------------
Solucion al inciso a) de la pregunta 4
---------------------------------------------------------------*/
/*----------------------------------------------------------------------------------
modifica_clase(Clase,Cambio,KB,Nuevo_KB) - cambia el nombre de una clase y considera 
                                           los cambios con sus clases hijos (modifica el nombre de la 
                                            clase madre tambien)
Clase: Clase de interes
Cambio: el nuevo nombre que se pondrá a la clase
KB: Base de conocimiento
Nuevo_KB: Base de conocimiento modificada

modifica_nom_objeto(Objeto,NuevoNombre,KB,NuevaKB) - cambia el nombre de un objeto y 
                                                    actualiza las relaciones que tenia
                                                    con otros
Objeto: Objeto al cual se quiere modificar
NuevoNombre: valor (nombre) nuevo del Objeto
KB: Base de Conocimiento
NuevaKB: Base de conocimiento modificada (nueva)                                                   
----------------------------------------------------------------------------------*/

modifica_clase(Clase,Cambio,KB,Salida):-
    open_kb(KB,Kb),modifica_c(Clase,Cambio,Kb,Kb2),save_kb(KB,Kb2),
    (Kb==Kb2->Salida='Base no modificada: Clase no encontrada';Salida='base modificada').

%si se quiere guardar en otro archivo
modifica_clase(Clase,Cambio,KB,Kb_nueva,Salida):-
    open_kb(KB,Kb),modifica_c(Clase,Cambio,Kb,Kb2),save_kb(Kb_nueva,Kb2),
    (Kb==Kb2->Salida='Base no modificada: Clase no encontrada';Salida='base modificada').

/*---------------------------------------------------------------------------*/

modifica_nom_objeto(_,_,[],[]):-!.
modifica_nom_objeto(NombreObjeto,NuevoNombre,Kb,Nueva_Kb):-
    cambia_nombre_obj(NombreObjeto,NuevoNombre,Kb,Kb1),
    corrige_relacion(NombreObjeto,NuevoNombre,Kb1,Nueva_Kb).



/*--------------------------------------------------------------
Solucion al inciso b) de la pregunta 4
---------------------------------------------------------------*/
/*----------------------------------------------------------------------------------
modifica_valor_propiedad_de_clase() - cambia el valor de una propiedad especifica de una Clase 
                                                                por una nueva
Clase: Clase de interes
Valor: el nuevo valor de la propiedad que se pondrá a la clase
KB: Base de conocimiento
Nuevo_KB: Base de conocimiento modificada

modifica_valor_propiedad_de_objeto() - cambia valor de una propiedad especifica de un Objeto de interes
                                                                reemplazando la(s) relacion(es) actuales 
Objeto: Objeto al cual se quiere modificar
Valor: el nuevo valor de la propiedad del Objeto
KB: Base de Conocimiento
NuevaKB: Base de conocimiento modificada (nueva)                                                   
----------------------------------------------------------------------------------*/



peso_de_propiedad(_,[],0).
peso_de_propiedad(Propiedad,[[Propiedad, Peso]|_],Peso).
peso_de_propiedad(Propiedad,[[Propiedad=>_, Peso]|_],Peso).
peso_de_propiedad(Propiedad,[_|T],Peso):-
    peso_de_propiedad(Propiedad,T,Peso).


modifica_valor_propiedad_de_clase(Clase,Propiedad,Valor,KB,NvoKB):-
    cambiaElemento(class(Clase,Madre,Propiedades,Relaciones,Objetos),class(Clase,Madre,Propiedades,Relaciones,Objetos),KB,_),
    peso_de_propiedad(Propiedad,Propiedades,Peso),
    eliminar_propiedad_clase(Clase,Propiedad, KB, Aux1),
    nva_Propiedad_Clase(Clase,Propiedad,Valor,Peso,Aux1,NvoKB). 


modifica_valor_propiedad_de_objeto(Objeto,Propiedad,Valor,KB,NvoKB):-
    cambiaElemento(class(Clase,Madre,Props,Rels,Objetos),class(Clase,Madre,Props,Rels,NvoObjetos),KB,_),
    esElemento([id=>Objeto,Propiedades,Relaciones],Objetos),
    cambiaElemento([id=>Objeto,Propiedades,Relaciones],[id=>Objeto,Propiedades,Relaciones],Objetos,NvoObjetos),
    peso_de_propiedad(Propiedad,Propiedades,Peso),
    eliminar_propiedad_objeto(Objeto,Propiedad,KB,Aux1),
    nva_Propiedad_Objeto(Objeto,Propiedad,Valor,Peso,Aux1,NvoKB). 





/*--------------------------------------------------------------
Solucion al inciso c) de la pregunta 4
---------------------------------------------------------------*/
/*----------------------------------------------------------------------------------
modifica_relacion_de_clase(Clase,Relacion,Cambio,KB,Nuevo_KB) - cambia la Relacion (o relaciones) de una Clase 
                                                                por una nueva
Clase: Clase de interes
Cambio: el nuevo nombre que se pondrá a la clase
KB: Base de conocimiento
Nuevo_KB: Base de conocimiento modificada

modifica_relacion_de_objeto(Objeto,Relacion,Cambio,KB,NuevaKB) - cambia la relacion de un Objeto de interes
                                                                reemplazando la(s) relacion(es) actuales 
Objeto: Objeto al cual se quiere modificar
Relacion: Relacion a buscar en el objeto
Cambio: el nuevo valor o valores de la Relacion del Objeto
KB: Base de Conocimiento
NuevaKB: Base de conocimiento modificada (nueva)                                                   
----------------------------------------------------------------------------------*/

modifica_relacion_de_clase(Clase,Relacion,Cambio,KB,Kb2):-
    open_kb(KB,Kb),
    modifica_relacion_de_c(Clase,Relacion,Cambio,Kb,Kb2),
    (Kb==Kb2->nl,write('======No se encontro la clase, Kb no modificada==========');
        nl,write('======Kb modificada==========='),nl).  


modifica_relacion_de_objeto(Objeto,Relacion,Cambio,KB,Kb2):-
    open_kb(KB,Kb),
    modifica_relacion_de_o(Objeto,Relacion,Cambio,Kb,Kb2),
    (Kb==Kb2->nl,write('======No se encontro la clase, Kb no modificada==========');
        nl,write('======Kb modificada==========='),nl). 