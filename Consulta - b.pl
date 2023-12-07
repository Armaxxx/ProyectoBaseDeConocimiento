% Verificar si un elemento X está en una lista
% isElement(X, Lista)
% Ejemplo (n, [b, a, n, a, n, a])

esElemento(X, [X|_]).
esElemento(X, [_|T]):-
    esElemento(X, T).

% Verificar si un objeto existe
existe_objeto(_, [], desconocido).

existe_objeto(Objeto, [class(_, _, _, _, O)|_], no):-
    esElemento([id=>not(Objeto), _, _], O).

existe_objeto(Objeto, [class(_, _, _, _, O)|_], si):-
    esElemento([id=>Objeto, _, _], O).

existe_objeto(Objeto, [_|T], Respuesta):-
    existe_objeto(Objeto, T, Respuesta).

% Verificar si una clase existe
existe_clase(_, [], desconocido).

existe_clase(Clase, [class(not(Clase), _, _, _, _)|_], no).

existe_clase(Clase, [class(Clase, _, _, _, _)|_], si).

existe_clase(Clase, [_|T], Respuesta):-
    existe_clase(Clase, T, Respuesta).

% Devolver el valor de una propiedad de clase
valor_propiedad_clase(Clase, Propiedad, KB, Valor):-
    propiedades_clase(Clase, KB, PropiedadesClase),
    encontrar_valor(Propiedad, PropiedadesClase, Valor).

encontrar_valor(_, [], desconocido).

encontrar_valor(Atributo, [Atributo=>Valor|_], Valor).

encontrar_valor(Atributo, [not(Atributo)|_], no).

encontrar_valor(Atributo, [Atributo|_], si).

encontrar_valor(Atributo, [_|T], Valor):-
    encontrar_valor(Atributo, T, Valor).

% Devolver los nombres de los objetos enlistados solo en una clase específica
objetos_solo_en_la_clase(_, [], desconocido).

objetos_solo_en_la_clase(Clase, [class(Clase, _, _, _, O)|_], Objetos):-
    extraer_nombres_objetos(O, Objetos).

objetos_solo_en_la_clase(Clase, [_|T], Objetos):-
    objetos_solo_en_la_clase(Clase, T, Objetos).

extraer_nombres_objetos([], []).

extraer_nombres_objetos([[id=>Nombre, _, _]|T], Objetos):-
    extraer_nombres_objetos(T, Resto),
    append([Nombre], Resto, Objetos).

% Devolver las clases hijas de una clase
clases_hijas_de_clase(Clase, KB, Respuesta):-
    existe_clase(Clase, KB, si),
    clases_hijas_de_una_clase(Clase, KB, Respuesta).

clases_hijas_de_clase(_, _, desconocido).

clases_hijas_de_una_clase(_, [], []).

clases_hijas_de_una_clase(Clase, [class(Hijo, Clase, _, _, _)|T], Hijas):-
    clases_hijas_de_una_clase(Clase, T, Hermanos),    
    append([Hijo], Hermanos, Hijas).

clases_hijas_de_una_clase(Clase, [_|T], Hijas):-
    clases_hijas_de_una_clase(Clase, T, Hijas).

% Devolver las clases hijas de una lista de clases de una clase
clases_hijas_de_lista_de_clases([], _, []).

clases_hijas_de_lista_de_clases([Hijo|T], KB, Nietos):-
    clases_hijas_de_una_clase(Hijo, KB, Hijos),
    clases_hijas_de_lista_de_clases(T, KB, Sobrinos),
    append(Hijos, Sobrinos, Nietos).

% Devolver todas las clases descendientes de una clase
clases_descendientes_de_clase(Clase, KB, Descendientes):-
    existe_clase(Clase, KB, si),
    clases_hijas_de_una_clase(Clase, KB, Hijos),
    todas_clases_descendientes_de_una_clase(Hijos, KB, Descendientes).

clases_descendientes_de_clase(_, _, desconocido).

todas_clases_descendientes_de_una_clase([], _, []).

todas_clases_descendientes_de_una_clase(Clases, KB, Descendientes):-
    clases_hijas_de_lista_de_clases(Clases, KB, Hijos),
    todas_clases_descendientes_de_una_clase(Hijos, KB, RestoDescendientes),
    append(Clases, RestoDescendientes, Descendientes).

% Devolver todos los objetos de una clase
objetos_de_clase(Clase, KB, Objetos):-
    existe_clase(Clase, KB, si),
    objetos_solo_en_la_clase(Clase, KB, ObjetosEnClase),
    clases_descendientes_de_clase(Clase, KB, Hijos),
    objetos_de_todas_clases_descendientes(Hijos, KB, ObjetosDescendientes),
    append(ObjetosEnClase, ObjetosDescendientes, Objetos).

objetos_de_clase(_, _, desconocido).

objetos_de_todas_clases_descendientes([], _, []).

objetos_de_todas_clases_descendientes([Clase|T], KB, TodosObjetos):-
    objetos_solo_en_la_clase(Clase, KB, Objetos),
    objetos_de_todas_clases_descendientes(T, KB, Resto),
    append(Objetos, Resto, TodosObjetos).

% Muestra la clase de un objeto
clase_de_objeto(_, [], desconocido):-!.

clase_de_objeto(Objeto, [class(C, _, _, _, O)|_], C):-
    esElemento([id=>Objeto, _, _], O).

clase_de_objeto(Objeto, [_|T], Clase):-
    clase_de_objeto(Objeto, T, Clase).

% Concatena las propiedades de los ancestros
concat_propiedades_ancestros([], _, []).

concat_propiedades_ancestros([Ancestro|T], KB, [Propiedades|NuevoT]):-
    concat_propiedades_ancestros(T, KB, NuevoT),
    propiedades_solo_en_la_clase(Ancestro, KB, Propiedades).

% Cancela los valores de propiedad repetidos
cancelar_valores_propiedad_repetidos(X, Z):-
    append_lista_de_listas(X, Y),
    eliminar_propiedades_repetidas(Y, Z).

% Convierte en una única lista una lista de listas
% Ejemplo ([[a],[b,c],[],[d]],[a,b,c,d]).

append_lista_de_listas([], []).

append_lista_de_listas([H|T], X):-
    append(H, TLista, X),
    append_lista_de_listas(T, TLista).

eliminar_propiedades_repetidas([], []).

lista_de_ancestros(top, _, []).

lista_de_ancestros(Clase, KB, Ancestros):-
    madre_de_una_clase(Clase, KB, Madre),
    append([Madre], Abuelos, Ancestros),
    lista_de_ancestros(Madre, KB, Abuelos).

% Consultar la madre de una clase
madre_de_una_clase(_, [], desconocido).

madre_de_una_clase(Clase, [class(Clase, Madre, _, _, _)|_], Madre).

madre_de_una_clase(Clase, [_|T], Madre):-
    madre_de_una_clase(Clase, T, Madre).

% Consultar las propiedades de una clase
propiedades_clase(top, KB, Propiedades):-
    propiedades_solo_en_la_clase(top, KB, Propiedades).

propiedades_clase(Clase, KB, Propiedades):-
    existe_clase(Clase, KB, si),
    propiedades_solo_en_la_clase(Clase, KB, PropiedadesClase),
    append([PropiedadesClase], PropiedadesAncestros, TodasPropiedades),
    concat_propiedades_ancestros(Ancestros, KB, PropiedadesAncestros),
    lista_de_ancestros(Clase, KB, Ancestros),
    cancelar_valores_propiedad_repetidos(TodasPropiedades, Propiedades).

propiedades_clase(Clase, KB, desconocido):-
    existe_clase(Clase, KB, desconocido).

propiedades_solo_en_la_clase(_, [], []).

propiedades_solo_en_la_clase(Clase, [class(Clase, _, Propiedades, _, _)|_], Propiedades).

propiedades_solo_en_la_clase(Clase, [_|T], Propiedades):-
    propiedades_solo_en_la_clase(Clase, T, Propiedades).

% Listar todas las propiedades de un objeto
propiedades_objeto(Objeto, KB, TodasPropiedades):-
    existe_objeto(Objeto, KB, si),
    propiedades_solo_en_el_objeto(Objeto, KB, PropiedadesObjeto),
    clase_de_objeto(Objeto, KB, Clase),
    propiedades_clase(Clase, KB, PropiedadesClase),
    append(PropiedadesObjeto, PropiedadesClase, Temp),
    eliminar_propiedades_repetidas(Temp, TodasPropiedades).

propiedades_objeto(_, _, desconocido).

propiedades_solo_en_el_objeto(_, [], []).

propiedades_solo_en_el_objeto(Objeto, [class(_, _, _, _, O)|_], Propiedades):-
    esElemento([id=>Objeto, Propiedades, _], O).

propiedades_solo_en_el_objeto(Objeto, [_|T], Propiedades):-
    propiedades_solo_en_el_objeto(Objeto, T, Propiedades).

% Devolver el valor de una propiedad de un objeto
valor_propiedad_objeto(Objeto, Propiedad, KB, Valor):-
    existe_objeto(Objeto, KB, si),
    propiedades_objeto(Objeto, KB, Propiedades),
    encontrar_valor(Propiedad, Propiedades, Valor).

valor_propiedad_objeto(_, _, _, desconocido).

% Extensión de Propiedad
property_extension(Propiedad, KB, Resultado):-
    objetos_de_clase(top, KB, TodosObjetos),
    filtrar_objetos_con_propiedad(KB, Propiedad, TodosObjetos, Objetos),
    eliminar_propiedad_nula(Objetos, Resultado).

filtrar_objetos_con_propiedad(_, _, [], []).

filtrar_objetos_con_propiedad(KB, Propiedad, [H|T], [H:Valor|NuevoT]):-
    valor_propiedad_objeto(H, Propiedad, KB, Valor),
    filtrar_objetos_con_propiedad(KB, Propiedad, T, NuevoT).

eliminar_propiedad_nula([], []).

eliminar_propiedad_nula([_:desconocido|T], NuevoT):-
    eliminar_propiedad_nula(T, NuevoT).

eliminar_propiedad_nula([X:Y|T], [X:Y|NuevoT]):-
    eliminar_propiedad_nula(T, NuevoT).