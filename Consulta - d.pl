classes_of_individual(Objeto, KB, Clases):-
    hay_objeto(Objeto, KB, si),
    clase_de_un_objeto(Objeto, KB, Clase),
    ancestros_de_clase(Clase, KB, Ancestros),
    append([Clase], Ancestros, Clases).
classes_of_individual(_, _, desconocido).

hay_objeto(_, [], desconocido).
hay_objeto(Objeto, [class(_,_,_,_,O)|_], no):-
    esElemento([id=>no(Objeto),_,_], O).
hay_objeto(Objeto, [class(_,_,_,_,O)|_], si):-
    esElemento([id=>Objeto,_,_], O).
hay_objeto(Objeto, [_|T], Respuesta):-
    hay_objeto(Objeto, T, Respuesta).

clase_de_un_objeto(_, [], desconocido):-!.
clase_de_un_objeto(Objeto, [class(C,_,_,_,O)|_], C):-
    esElemento([id=>Objeto,_,_], O).
clase_de_un_objeto(Objeto, [_|T], Clase):-
    clase_de_un_objeto(Objeto, T, Clase).

ancestros_de_clase(Clase, KB, Ancestros):-
    hay_clase(Clase, KB, si),
    lista_de_ancestros(Clase, KB, Ancestros).
ancestros_de_clase(Clase, KB, desconocido):-
    hay_clase(Clase, KB, desconocido).

lista_de_ancestros(top, _, []).
lista_de_ancestros(Clase, KB, Ancestros):-
    madre_de_una_clase(Clase, KB, Madre),
    append([Madre], Abuelos, Ancestros),
    lista_de_ancestros(Madre, KB, Abuelos).

esElemento(X, [X|_]).
esElemento(X, [_|T]):-
    esElemento(X, T).

hay_clase(_, [], desconocido).
hay_clase(Clase, [class(no(Clase),_,_,_,_)|_], no).
hay_clase(Clase, [class(Clase,_,_,_,_)|_], si).
hay_clase(Clase, [_|T], Respuesta):-
    hay_clase(Clase, T, Respuesta).

madre_de_una_clase(_, [], desconocido).
madre_de_una_clase(Clase, [class(Clase, Madre, _, _, _)|_], Madre).
madre_de_una_clase(Clase, [_|T], Madre):-
    madre_de_una_clase(Clase, T, Madre).
