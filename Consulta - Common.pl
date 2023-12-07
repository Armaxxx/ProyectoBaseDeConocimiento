existe_clase(_,[],unknown).
existe_clase(Clase,[class(not(Clase),_,_,_,_)|_],no).
existe_clase(Clase,[class(Clase,_,_,_,_)|_],yes).
existe_clase(Clase,[_|T],Respuesta):-
	existe_clase(Clase,T,Respuesta).
objetos_solo_en_la_clase(_,[],unknown).
objetos_solo_en_la_clase(Clase,[class(Clase,_,_,_,O)|_],Objetos):-
	extraer_nombres_de_objetos(O,Objetos).
objetos_solo_en_la_clase(Clase,[_|T],Objetos):-
	objetos_solo_en_la_clase(Clase,T,Objetos).
extraer_nombres_de_objetos([],[]).
extraer_nombres_de_objetos([[id=>Nombre,_,_]|T],Objetos):-
	extraer_nombres_de_objetos(T,Rest),
	append([Nombre],Rest,Objetos).
clases_hijas_de_clase(Clase,KB,Respuesta):-
	existe_clase(Clase,KB,yes),
	clases_hijas_de_una_clase(Clase,KB,Respuesta).
clases_hijas_de_clase(_,_,unknown).
clases_hijas_de_una_clase(_,[],[]).
clases_hijas_de_una_clase(Clase,[class(Hijo,Clase,_,_,_)|T],Hijas):-
	clases_hijas_de_una_clase(Clase,T,Hermanos),	
	append([Hijo],Hermanos,Hijas).
clases_hijas_de_una_clase(Clase,[_|T],Hijas):-
	clases_hijas_de_una_clase(Clase,T,Hijas).
clases_hijas_de_lista_de_clases([],_,[]).
clases_hijas_de_lista_de_clases([Hijo|T],KB,Nietos):-
	clases_hijas_de_una_clase(Hijo,KB,Hijos),
	clases_hijas_de_lista_de_clases(T,KB,Sobrinos),
	append(Hijos,Sobrinos,Nietos).
clases_descendientes_de_clase(Clase,KB,Descendientes):-
	existe_clase(Clase,KB,yes),
	clases_hijas_de_una_clase(Clase,KB,Hijos),
	todas_clases_descendientes_de_una_clase(Hijos,KB,Descendientes).
clases_descendientes_de_clase(_,_,unknown).
todas_clases_descendientes_de_una_clase([],_,[]).
todas_clases_descendientes_de_una_clase(Clases,KB,Descendientes):-
	clases_hijas_de_lista_de_clases(Clases,KB,Hijos),
	todas_clases_descendientes_de_una_clase(Hijos,KB,RestoDescendientes),
	append(Clases,RestoDescendientes,Descendientes).
objetos_de_clase(Clase,KB,Objetos):-
	existe_clase(Clase,KB,yes),
	objetos_solo_en_la_clase(Clase,KB,ObjetosEnClase),
	clases_descendientes_de_clase(Clase,KB,Hijos),
	objetos_de_todas_clases_descendientes(Hijos,KB,ObjetosDescendientes),
	append(ObjetosEnClase,ObjetosDescendientes,Objetos).
objetos_de_clase(_,_,unknown).
objetos_de_todas_clases_descendientes([],_,[]).
objetos_de_todas_clases_descendientes([Clase|T],KB,TodosObjetos):-
	objetos_solo_en_la_clase(Clase,KB,Objetos),
	objetos_de_todas_clases_descendientes(T,KB,Resto),
	append(Objetos,Resto,TodosObjetos).
clase_de_objeto(_, [], unknown):-!.
clase_de_objeto(Objeto, [class(C, _, _, _, O)|_], C):-
    esElemento([id=>Objeto, _, _], O).
clase_de_objeto(Objeto, [_|T], Clase):-
    clase_de_objeto(Objeto, T, Clase).
madre_de_una_clase(_, [], unknown).
madre_de_una_clase(Clase, [class(Clase, Madre, _, _, _)|_], Madre).
madre_de_una_clase(Clase, [_|T], Madre):-
    madre_de_una_clase(Clase, T, Madre).
esElemento(X, [X|_]).
esElemento(X, [_|T]):-
    esElemento(X, T).
lista_de_ancestros(top, _, []).
lista_de_ancestros(Clase, KB, Ancestros):-
    madre_de_una_clase(Clase, KB, Madre),
    append([Madre], Abuelos, Ancestros),
    lista_de_ancestros(Madre, KB, Abuelos).
existe_objeto(_, [], unknown).
existe_objeto(Objeto, [class(_, _, _, _, O)|_], no):-
    esElemento([id=>not(Objeto), _, _], O).
existe_objeto(Objeto, [class(_, _, _, _, O)|_], yes):-
    esElemento([id=>Objeto, _, _], O).
existe_objeto(Objeto, [_|T], Respuesta):-
    existe_objeto(Objeto, T, Respuesta).
eliminar_propiedad_nula([], []).
eliminar_propiedad_nula([_:unknown | T], NuevaT) :-
    eliminar_propiedad_nula(T, NuevaT).
eliminar_propiedad_nula([X:Y | T], [X:Y | NuevaT]) :-
    eliminar_propiedad_nula(T, NuevaT).
eliminar_propiedades_repetidas([], []).
eliminar_propiedades_repetidas([P=>V|T], [P=>V|NuevaT]):-
    eliminar_todos_elementos_con_la_misma_propiedad(P, T, L1),
    eliminar_elemento(not(P=>V), L1, L2),
    eliminar_propiedades_repetidas(L2, NuevaT).
eliminar_propiedades_repetidas([not(P=>V)|T], [not(P=>V)|NuevaT]):-
    eliminar_todos_elementos_con_la_misma_propiedad(P, T, L1),
    eliminar_elemento(P=>V, L1, L2),
    eliminar_propiedades_repetidas(L2, NuevaT).
eliminar_propiedades_repetidas([not(H)|T], [not(H)|NuevaT]):-
    eliminar_elemento(not(H), T, L1),
    eliminar_elemento(H, L1, L2),
    eliminar_propiedades_repetidas(L2, NuevaT).
eliminar_propiedades_repetidas([H|T], [H|NuevaT]):-
    eliminar_elemento(H, T, L1),
    eliminar_elemento(not(H), L1, L2),
    eliminar_propiedades_repetidas(L2, NuevaT).
clase_de_un_objeto(_, [], unknown):-!.
clase_de_un_objeto(Objeto, [class(C,_,_,_,O)|_], C):-
    esElemento([id=>Objeto,_,_], O).
clase_de_un_objeto(Objeto, [_|T], Clase):-
    clase_de_un_objeto(Objeto, T, Clase).
concatenar_relaciones_de_ancestros([],_,[]).
concatenar_relaciones_de_ancestros([Ancestro|T],KB,[Relaciones|NuevaT]):-
    concatenar_relaciones_de_ancestros(T,KB,NuevaT),
    solo_relaciones_en_la_clase(Ancestro,KB,Relaciones).
hijos_de_una_clase(_,_,unknown).
hijos_de_una_clase(_,[],[]).
hijos_de_una_clase(Class,[class(Hijo,Class,_,_,_)|T],Hijos):-
	hijos_de_una_clase(Class,T,Hermanos),	
	append([Hijo],Hermanos,Hijos).
hijos_de_una_clase(Class,[_|T],Sons):-
	hijos_de_una_clase(Class,T,Sons).	
descendientes_de_una_clase(Clase,KB,Descendientes):-
    existe_clase(Clase,KB,yes),
    hijos_de_una_clase(Clase,KB,Hijos),
    todos_los_descendientes_de_una_clase(Hijos,KB,Descendientes).
descendientes_de_una_clase(_,_,unknown).
ancestros_de_clase(Clase, KB, Ancestros) :-
    existe_clase(Clase, KB, yes),
    lista_de_ancestros(Clase, KB, Ancestros).
ancestros_de_clase(Clase, KB, unknown) :-
    existe_clase(Clase, KB, unknown).
propiedades_solo_en_la_clase(_, [], []).
propiedades_solo_en_la_clase(Clase, [class(Clase, _, Propiedades, _, _)|_], Propiedades).
propiedades_solo_en_la_clase(Clase, [_|T], Propiedades):-
    propiedades_solo_en_la_clase(Clase, T, Propiedades).
eliminar_elemento(_, [], []).
eliminar_elemento(X, [X | T], NuevaT) :-
    eliminar_elemento(X, T, NuevaT).
eliminar_elemento(X, [H | T], [H | NuevaT]) :-
    eliminar_elemento(X, T, NuevaT),
    X \= H.
cancelar_valores_propiedad_repetidos(X, Z):-
    append_lista_de_listas(X, Y),
    eliminar_propiedades_repetidas(Y, Z).