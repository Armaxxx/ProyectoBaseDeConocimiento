% Muestra la clase de un objeto

clase_de_objeto(_, [], desconocido) :- !.
clase_de_objeto(Objeto, [class(C, _, _, _, O) | _], C) :-
    es_elemento([id => Objeto, _, _], O).
clase_de_objeto(Objeto, [_ | T], Clase) :-
    clase_de_objeto(Objeto, T, Clase).

% Consulta la madre de una clase

madre_de_una_clase(_, [], desconocido).
madre_de_una_clase(Clase, [class(Clase, Madre, _, _, _) | _], Madre).
madre_de_una_clase(Clase, [_ | T], Madre) :-
    madre_de_una_clase(Clase, T, Madre).

% Verifica si una clase existe

existe_clase(_, [], desconocido).
existe_clase(Clase, [class(not(Clase), _, _, _, _) | _], no).
existe_clase(Clase, [class(Clase, _, _, _, _) | _], si).
existe_clase(Clase, [_ | T], Respuesta) :-
    existe_clase(Clase, T, Respuesta).

% Devuelve el valor de una relación de clase

valor_relacion_clase(Clase, Relacion, KB, Valor) :-
    existe_clase(Clase, KB, si),
    relaciones_clase(Clase, KB, Relaciones),
    encontrar_valor_relacion(Relacion, Relaciones, Valor).

valor_relacion_clase(_, _, _, desconocido).

encontrar_valor_relacion(not(Relacion), Relaciones, Valor) :-
    encontrar_valor_relacion_negativa(Relacion, Relaciones, Valor).
encontrar_valor_relacion(Relacion, Relaciones, Valor) :-
    encontrar_valor_relacion_positiva(Relacion, Relaciones, Valor).

encontrar_valor_relacion_negativa(_, [], desconocido).
encontrar_valor_relacion_negativa(Atributo, [not(Atributo => Valor) | _], Valor).
encontrar_valor_relacion_negativa(Atributo, [_ | T], Valor) :-
    encontrar_valor_relacion_negativa(Atributo, T, Valor).

encontrar_valor_relacion_positiva(_, [], desconocido).
encontrar_valor_relacion_positiva(Atributo, [Atributo => Valor | _], Valor).
encontrar_valor_relacion_positiva(Atributo, [_ | T], Valor) :-
    encontrar_valor_relacion_positiva(Atributo, T, Valor).

% Verifica si un elemento X está en una lista

es_elemento(X, [X | _]).
es_elemento(X, [_ | T]) :-
    es_elemento(X, T).

% Devuelve las clases hijas de una clase

hijos_de_clase(Clase, KB, Respuesta) :-
    existe_clase(Clase, KB, si),
    hijos_de_una_clase(Clase, KB, Respuesta).

hijos_de_clase(_, _, desconocido).

hijos_de_una_clase(_, [], []).

hijos_de_una_clase(Clase, [class(Hijo, Clase, _, _, _) | T], Hijos) :-
    hijos_de_una_clase(Clase, T, Hermanos),
    append([Hijo], Hermanos, Hijos).

hijos_de_una_clase(Clase, [_ | T], Hijos) :-
    hijos_de_una_clase(Clase, T, Hijos).

% Consulta los ancestros de una clase

ancestros_de_clase(Clase, KB, Ancestros) :-
    existe_clase(Clase, KB, si),
    lista_de_ancestros(Clase, KB, Ancestros).

ancestros_de_clase(Clase, KB, desconocido) :-
    existe_clase(Clase, KB, desconocido).

lista_de_ancestros(top, _, []).

lista_de_ancestros(Clase, KB, Ancestros) :-
    madre_de_una_clase(Clase, KB, Madre),
    append([Madre], Abuelos, Ancestros),
    lista_de_ancestros(Madre, KB, GrandParents).

% Consulta las relaciones de una clase

relaciones_clase(top, KB, Relaciones) :-
    relaciones_solo_en_la_clase(top, KB, Relaciones).

relaciones_clase(Clase, KB, Relaciones) :-
    existe_clase(Clase, KB, si),
    relaciones_solo_en_la_clase(Clase, KB, RelacionesClase),
    append([RelacionesClase], RelacionesAncestros, TodasLasRelaciones),
    concatenar_relaciones_de_ancestros(Ancestros, KB, RelacionesAncestros),
    lista_de_ancestros(Clase, KB, Ancestros),
    eliminar_propiedades_repetidas(TodasLasRelaciones, Relaciones).

relaciones_clase(_, _, desconocido).

relaciones_solo_en_la_clase(_, [], []).

relaciones_solo_en_la_clase(Clase, [class(Clase, _, _, Relaciones, _) | _], Relaciones).

relaciones_solo_en_la_clase(Clase, [_ | T], Relaciones) :-
    relaciones_solo_en_la_clase(Clase, T, Relaciones).

concatenar_relaciones_de_ancestros([], _, []).

concatenar_relaciones_de_ancestros([Ancestro | T], KB, [Relaciones | NuevaT]) :-
    concatenar_relaciones_de_ancestros(T, KB, NuevaT),
    relaciones_solo_en_la_clase(Ancestro, KB, Relaciones).

% Verifica si un objeto existe

existe_objeto(_, [], desconocido).

existe_objeto(Objeto, [class(_, _, _, _, O) | _], no) :-
    es_elemento([id => not(Objeto), _, _], O).

existe_objeto(Objeto, [class(_, _, _, _, O) | _], si) :-
    es_elemento([id => Objeto, _, _], O).

existe_objeto(Objeto, [_ | T], Respuesta) :-
    existe_objeto(Objeto, T, Respuesta).

eliminar_propiedad_nula([], []).

eliminar_propiedad_nula([_:desconocido | T], NuevaT) :-
    eliminar_propiedad_nula(T, NuevaT).

eliminar_propiedad_nula([X:Y | T], [X:Y | NuevaT]) :-
    eliminar_propiedad_nula(T, NuevaT).
% Elimina todas las ocurrencias de un elemento X en una lista

eliminar_elemento(_, [], []).

eliminar_elemento(X, [X | T], NuevaT) :-
    eliminar_elemento(X, T, NuevaT).

eliminar_elemento(X, [H | T], [H | NuevaT]) :-
    eliminar_elemento(X, T, NuevaT),
    X \= H.
% Concatena una lista de listas en una sola lista

concatenar_listas([], []).

concatenar_listas([H | T], X) :-
    append(H, TLista, X),
    concatenar_listas(T, TLista).
% Elimina todas las propiedades repetidas en una lista de propiedades-valor

eliminar_propiedades_repetidas(X, Z) :-
    concatenar_listas(X, Y),
    eliminar_propiedad_repetida(Y, Z).

eliminar_propiedad_repetida([], []).

eliminar_propiedad_repetida([P => V | T], [P => V | NuevaT]) :-
    eliminar_elemento(P => V, T, L1),
    eliminar_propiedad_repetida(L1, NuevaT).

eliminar_propiedad_repetida([not(P => V) | T], [not(P => V) | NuevaT]) :-
    eliminar_elemento(not(P => V), T, L1),
    eliminar_elemento(P => V, L1, L2),
    eliminar_propiedad_repetida(L2, NuevaT).

eliminar_propiedad_repetida([not(H) | T], [not(H) | NuevaT]) :-
    eliminar_elemento(not(H), T, L1),
    eliminar_elemento(H, L1, L2),
    eliminar_propiedad_repetida(L2, NuevaT).

eliminar_propiedad_repetida([H | T], [H | NuevaT]) :-
    eliminar_elemento(H, T, L1),
    eliminar_elemento(not(H), L1, L2),
    eliminar_propiedad_repetida(L2, NuevaT).


% Devuelve todas las clases descendientes de una clase

descendientes_de_una_clase(Clase, KB, Descendientes) :-
    existe_clase(Clase, KB, si),
    hijos_de_una_clase(Clase, KB, Hijos),
    todas_descendientes_de_una_clase(Hijos, KB, Descendientes).

descendientes_de_una_clase(_, _, desconocido).

todas_descendientes_de_una_clase([], _, []).

todas_descendientes_de_una_clase(Clases, KB, Descendientes) :-
    hijos_de_lista_de_clases(Clases, KB, Hijos),
    todas_descendientes_de_una_clase(Hijos, KB, RestoDescendientes),
    append(Clases, RestoDescendientes, Descendientes).

% Devuelve los hijos de una lista de clases de una clase

hijos_de_lista_de_clases([], _, []).

hijos_de_lista_de_clases([Hijo | T], KB, Nietos) :-
    hijos_de_una_clase(Hijo, KB, Hijos),
    hijos_de_lista_de_clases(T, KB, Sobrinos),
    append(Hijos, Sobrinos, Nietos).
