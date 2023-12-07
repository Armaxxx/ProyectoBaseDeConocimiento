properties_of_individual(Objeto, KB, Propiedades):-
    propiedades_de_objeto(Objeto, KB, Propiedades).
propiedades_de_objeto(Objeto, KB, TodasLasPropiedades):-
    hay_objeto(Objeto, KB, si),
    propiedades_solo_en_objeto(Objeto, KB, PropiedadesObjeto),
    clase_de_un_objeto(Objeto, KB, Clase),
    propiedades_de_clase(Clase, KB, PropiedadesClase),
    append(PropiedadesObjeto, PropiedadesClase, Temp),
    eliminar_propiedades_repetidas(Temp, TodasLasPropiedades).
propiedades_de_objeto(_, _, desconocido).
propiedades_solo_en_objeto(_, [], []).
propiedades_solo_en_objeto(Objeto, [class(_, _, _, _, O)|_], Propiedades):-
    esElemento([id=>Objeto, Propiedades, _], O).
propiedades_solo_en_objeto(Objeto, [_|T], Propiedades):-
    propiedades_solo_en_objeto(Objeto, T, Propiedades).
hay_objeto(_, [], desconocido).
hay_objeto(Objeto, [class(_, _, _, _, O)|_], no):-
    esElemento([id=>not(Objeto), _, _], O).
hay_objeto(Objeto, [class(_, _, _, _, O)|_], si):-
    esElemento([id=>Objeto, _, _], O).
hay_objeto(Objeto, [_|T], Respuesta):-
    hay_objeto(Objeto, T, Respuesta).
clase_de_un_objeto(_, [], desconocido):-!.
clase_de_un_objeto(Objeto, [class(C, _, _, _, O)|_], C):-
    esElemento([id=>Objeto, _, _], O).
clase_de_un_objeto(Objeto, [_|T], Clase):-
    clase_de_un_objeto(Objeto, T, Clase).
propiedades_de_clase(top, KB, Propiedades):-
    propiedades_solo_en_la_clase(top, KB, Propiedades).
propiedades_de_clase(Clase, KB, Propiedades):-
    hay_clase(Clase, KB, si),
    propiedades_solo_en_la_clase(Clase, KB, PropiedadesClase),
    append([PropiedadesClase], PropiedadesAncestros, TodasLasPropiedades),
    concatenar_propiedades_de_ancestros(Ancestros, KB, PropiedadesAncestros),
    lista_de_ancestros(Clase, KB, Ancestros),
    cancelar_propiedades_repetidas(TodasLasPropiedades, Propiedades).
propiedades_de_clase(Clase, KB, desconocido):-
    hay_clase(Clase, KB, desconocido).
propiedades_solo_en_la_clase(_, [], []).
propiedades_solo_en_la_clase(Clase, [class(Clase, _, Propiedades, _, _)|_], Propiedades).
propiedades_solo_en_la_clase(Clase, [_|T], Propiedades):-
    propiedades_solo_en_la_clase(Clase, T, Propiedades).
concatenar_propiedades_de_ancestros([], _, []).
concatenar_propiedades_de_ancestros([Ancestro|T], KB, [Propiedades|NuevaT]):-
    concatenar_propiedades_de_ancestros(T, KB, NuevaT),
    propiedades_solo_en_la_clase(Ancestro, KB, Propiedades).
cancelar_propiedades_repetidas(X, Z):-
    concatenar_listas_de_listas(X, Y),
    eliminar_propiedades_repetidas(Y, Z).
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
esElemento(X, [X|_]).
esElemento(X, [_|T]):-
    esElemento(X, T).
hay_clase(_, [], desconocido).
hay_clase(Clase, [class(not(Clase), _, _, _, _)|_], no).
hay_clase(Clase, [class(Clase, _, _, _, _)|_], si).
hay_clase(Clase, [_|T], Respuesta):-
    hay_clase(Clase, T, Respuesta).
lista_de_ancestros(top, _, []).
lista_de_ancestros(Clase, KB, Ancestros):-
    madre_de_una_clase(Clase, KB, Madre),
    append([Madre], Abuelos, Ancestros),
    lista_de_ancestros(Madre, KB, Abuelos).
append_list_of_lists([], []).
append_list_of_lists([H|T], X):-
    append(H, TList, X),
    append_list_of_lists(T, TList).
eliminar_todos_elementos_con_la_misma_propiedad(_, [], []).
eliminar_todos_elementos_con_la_misma_propiedad(X, [X=>_|T], NuevaT):-
    eliminar_todos_elementos_con_la_misma_propiedad(X, T, NuevaT).
eliminar_todos_elementos_con_la_misma_propiedad(X, [H|T], NuevaT):-
    eliminar_todos_elementos_con_la_misma_propiedad(X, T, NuevaT),
    X \= H.
eliminar_elemento(_, [], []).
eliminar_elemento(X, [X|T], NuevaT):-
    eliminar_elemento(X, T, NuevaT).
eliminar_elemento(X, [H|T], [H|NuevaT]):-
    eliminar_elemento(X, T, NuevaT),
    X \= H.
eliminar_todos_elementos_con_la_misma_propiedad_negada(_, [], []).
eliminar_todos_elementos_con_la_misma_propiedad_negada(X, [not(X=>_)|T], NuevaT):-
    eliminar_todos_elementos_con_la_misma_propiedad_negada(X, T, NuevaT).
eliminar_todos_elementos_con_la_misma_propiedad_negada(X, [H|T], NuevaT):-
    eliminar_todos_elementos_con_la_misma_propiedad_negada(X, T, NuevaT),
    X \= not(X=>H).
madre_de_una_clase(_, [], desconocido).
madre_de_una_clase(Clase, [class(Clase, Madre, _, _, _)|_], Madre).
madre_de_una_clase(Clase, [_|T], Madre):-
    madre_de_una_clase(Clase, T, Madre).
concatenar_listas_de_listas([], []).
concatenar_listas_de_listas([Lista|Resto], Concatenadas):-
    append(Lista, ListaConcatenada, Concatenadas),
    concatenar_listas_de_listas(Resto, ListaConcatenada).