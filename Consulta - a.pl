% Devolver los nombres de los objetos enlistados solo en una clase específica
objetos_solo_en_la_clase(_,[],desconocido).

objetos_solo_en_la_clase(Clase,[class(Clase,_,_,_,O)|_],Objetos):-
	extraer_nombres_de_objetos(O,Objetos).

objetos_solo_en_la_clase(Clase,[_|T],Objetos):-
	objetos_solo_en_la_clase(Clase,T,Objetos).
	
extraer_nombres_de_objetos([],[]).

extraer_nombres_de_objetos([[id=>Nombre,_,_]|T],Objetos):-
	extraer_nombres_de_objetos(T,Rest),
	append([Nombre],Rest,Objetos).

% Verificar si una clase existe
existe_clase(_,[],desconocido).

existe_clase(Clase,[class(not(Clase),_,_,_,_)|_],no).

existe_clase(Clase,[class(Clase,_,_,_,_)|_],si).

existe_clase(Clase,[_|T],Respuesta):-
	existe_clase(Clase,T,Respuesta).

% Devolver las clases hijas de una clase
clases_hijas_de_clase(Clase,KB,Respuesta):-
	existe_clase(Clase,KB,si),
	clases_hijas_de_una_clase(Clase,KB,Respuesta).

clases_hijas_de_clase(_,_,desconocido).

clases_hijas_de_una_clase(_,[],[]).

clases_hijas_de_una_clase(Clase,[class(Hijo,Clase,_,_,_)|T],Hijas):-
	clases_hijas_de_una_clase(Clase,T,Hermanos),	
	append([Hijo],Hermanos,Hijas).

clases_hijas_de_una_clase(Clase,[_|T],Hijas):-
	clases_hijas_de_una_clase(Clase,T,Hijas).

% Devolver las clases hijas de una lista de clases de una clase
clases_hijas_de_lista_de_clases([],_,[]).

clases_hijas_de_lista_de_clases([Hijo|T],KB,Nietos):-
	clases_hijas_de_una_clase(Hijo,KB,Hijos),
	clases_hijas_de_lista_de_clases(T,KB,Sobrinos),
	append(Hijos,Sobrinos,Nietos).

% Devolver todas las clases descendientes de una clase
clases_descendientes_de_clase(Clase,KB,Descendientes):-
	existe_clase(Clase,KB,si),
	clases_hijas_de_una_clase(Clase,KB,Hijos),
	todas_clases_descendientes_de_una_clase(Hijos,KB,Descendientes).

clases_descendientes_de_clase(_,_,desconocido).

todas_clases_descendientes_de_una_clase([],_,[]).

todas_clases_descendientes_de_una_clase(Clases,KB,Descendientes):-
	clases_hijas_de_lista_de_clases(Clases,KB,Hijos),
	todas_clases_descendientes_de_una_clase(Hijos,KB,RestoDescendientes),
	append(Clases,RestoDescendientes,Descendientes).

% Devolver todos los objetos de una clase
objetos_de_clase(Clase,KB,Objetos):-
	existe_clase(Clase,KB,si),
	objetos_solo_en_la_clase(Clase,KB,ObjetosEnClase),
	clases_descendientes_de_clase(Clase,KB,Hijos),
	objetos_de_todas_clases_descendientes(Hijos,KB,ObjetosDescendientes),
	append(ObjetosEnClase,ObjetosDescendientes,Objetos).

objetos_de_clase(_,_,desconocido).

objetos_de_todas_clases_descendientes([],_,[]).

objetos_de_todas_clases_descendientes([Clase|T],KB,TodosObjetos):-
	objetos_solo_en_la_clase(Clase,KB,Objetos),
	objetos_de_todas_clases_descendientes(T,KB,Resto),
	append(Objetos,Resto,TodosObjetos).

% Extensión de Clase
class_extension(Clase,KB,Objetos):-
	objetos_de_clase(Clase,KB,Objetos).

%------------------------------------------------------------------------------------------------------
%------------------------------------------------------------------------------------------------------
