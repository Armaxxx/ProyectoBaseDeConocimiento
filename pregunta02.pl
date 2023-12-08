/*----------------------------------------------------------------------------------
Solución del inciso a) de la pregunta 2:

add_class(ClassName, MotherClass, KB, NewKB) - Añadir clase a la clase madre
    ClassName: Clase nueva que se va a añadir
    MotherClass: Nombre de la clase madre sobre la que se va a crear
    KB: Base de conocimientos original
    NewKB: Nueva base de conocimientos

add_object(ObjectID, ClassName, KB, NewKB) - Añadir objeto a una clase
    ObjectID: Identificador del objeto que se va a añadir
    ClassName: Nombre de la clase dónde se añadirá el objeto
    KB: Base de conocimientos original
    NewKB: Nueva base de conocimientos
----------------------------------------------------------------------------------*/

% Predicado para añadir una nueva clase
add_class(ClassName, MotherClass, KB, NewKB) :-
    % Aseguramos que la clase no exista ya en la base de conocimientos
    \+ class(ClassName, _, _, _, _),
    % Verificamos que la clase madre sí exista
    class(MotherClass, _, _, _, _),
    % Añadimos la nueva clase a la base de conocimientos
    NewClass = class(ClassName, MotherClass, [], [], []),
    NewKB = [NewClass | KB].

% Predicado para añadir un nuevo objeto
add_object(ObjectID, ClassName, KB, NewKB) :-
    % Aseguramos que el objeto no exista ya en la base de conocimientos
    \+ member(class(_, _, _, _, _), KB),
    \+ member([id=>ObjectID, _, _], _),
    % Verificamos que la clase a la cual se añadirá el objeto sí exista
    member(class(ClassName, Mother, Attrs, Rel, _), KB),
    % Añadimos el nuevo objeto a la lista de objetos de la clase
    NewObject = [id=>ObjectID, [], []],
    NewObjectsList = [NewObject | Objects],
    % Reemplazamos la vieja lista de objetos con la nueva lista
    NewClass = class(ClassName, Mother, Attrs, Rel, NewObjectsList),
    % Remplazamos la vieja clase con la nueva clase en la base de conocimientos
    select(class(ClassName, Mother, Attrs, Rel, Objects), KB, NewClass, NewKB).


/*----------------------------------------------------------------------------------
Solución del inciso b) de la pregunta 2:

add_class_property(ClassName, PropertyName, PropertyValue, KB, NewKB) - Añade una nueva propiedad
    ClassName: Clase a la que se le añadirá la propiedad
    PropertyName: nombre de la propiedad
    PropertyValue: valor de dicha propiedad
    KB: Base de conocimientos original
    NewKB: Nueva base de conocimientos

add_object_property(ObjectId, PropertyName, PropertyValue, KB, NewKB)  - Añadir propiedad al objeto 
    ObjectID: Identificador del objeto que se va a añadir
    PropertyName: nombre de la propiedad
    PropertyValue: valor de dicha propiedad
    KB: Base de conocimientos original
    NewKB: Nueva base de conocimientos
----------------------------------------------------------------------------------*/


% Predicado para añadir una propiedad a una clase
add_class_property(ClassName, PropertyName, PropertyValue, KB, NewKB) :-
    % Encuentra la clase y extrae sus componentes
    select(class(ClassName, Mother, Attrs, Rel, Objects), KB, RestKB),
    % Crea una nueva propiedad
    NewProperty =.. [PropertyName, PropertyValue],
    % Añade la nueva propiedad a la lista de atributos de la clase
    NewAttrs = [NewProperty | Attrs],
    % Crea la nueva clase con la propiedad añadida
    NewClass = class(ClassName, Mother, NewAttrs, Rel, Objects),
    % Añade la nueva clase a la base de conocimientos
    NewKB = [NewClass | RestKB].

% Predicado para añadir una propiedad a un objeto
add_object_property(ObjectId, PropertyName, PropertyValue, KB, NewKB) :-
    % Encuentra la clase que contiene el objeto
    member(class(ClassName, Mother, Attrs, Rel, Objects), KB),
    % Encuentra el objeto y extrae sus componentes
    select([id=>ObjectId, ObjAttrs, ObjRel], Objects, RestObjects),
    % Crea una nueva propiedad
    NewProperty =.. [PropertyName, PropertyValue],
    % Añade la nueva propiedad a la lista de atributos del objeto
    NewObjAttrs = [NewProperty | ObjAttrs],
    % Crea el nuevo objeto con la propiedad añadida
    NewObject = [id=>ObjectId, NewObjAttrs, ObjRel],
    % Crea la nueva lista de objetos con el objeto actualizado
    NewObjectsList = [NewObject | RestObjects],
    % Crea la clase actualizada con la nueva lista de objetos
    NewClass = class(ClassName, Mother, Attrs, Rel, NewObjectsList),
    % Reemplaza la clase antigua por la clase actualizada en la base de conocimientos
    select(class(ClassName, Mother, Attrs, Rel, Objects), KB, NewClass, NewKB).

/*----------------------------------------------------------------------------------
Solución del inciso c) de la pregunta 2:

add_class_relation(ClassName, RelationName, RelatedClasses, KB, NewKB) - Añade una nueva relación a una clase
    ClassName: Clase a la que se le añadirá la relación
    RelationName: nombre de la relación a añadir
    RelatedClasses: clases con quienes se guarda la relación
    KB: Base de conocimientos original
    NewKB: Nueva base de conocimientos

add_object_relation(ObjectId, RelationName, RelatedObjects, KB, NewKB) - Añade una nueva relación a un objeto
    ObjectID: Identificador del objeto al que se va a añadir la relación
    RelationName: nombre de la relación a añadir
    RelatedObjects: objetos con quienes se guarda la relación
    KB: Base de conocimientos original
    NewKB: Nueva base de conocimientos
----------------------------------------------------------------------------------*/


% Predicado para añadir una relación a una clase
add_class_relation(ClassName, RelationName, RelatedClasses, KB, NewKB) :-
    % Encuentra la clase y extrae sus componentes
    select(class(ClassName, Mother, Attrs, Rel, Objects), KB, RestKB),
    % Crea una nueva relación
    NewRelation =.. [RelationName, RelatedClasses],
    % Añade la nueva relación a la lista de relaciones de la clase
    NewRel = [NewRelation | Rel],
    % Crea la nueva clase con la relación añadida
    NewClass = class(ClassName, Mother, Attrs, NewRel, Objects),
    % Añade la nueva clase a la base de conocimientos
    NewKB = [NewClass | RestKB].

% Predicado para añadir una relación a un objeto
add_object_relation(ObjectId, RelationName, RelatedObjects, KB, NewKB) :-
    % Encuentra la clase que contiene el objeto y extrae sus componentes
    member(class(ClassName, Mother, Attrs, Rel, Objects), KB),
    % Encuentra el objeto y extrae sus atributos y relaciones
    select([id=>ObjectId, ObjAttrs, ObjRel], Objects, RestObjects),
    % Crea una nueva relación
    NewRelation =.. [RelationName, RelatedObjects],
    % Añade la nueva relación a la lista de relaciones del objeto
    NewObjRel = [NewRelation | ObjRel],
    % Crea el nuevo objeto con la relación añadida
    NewObject = [id=>ObjectId, ObjAttrs, NewObjRel],
    % Crea la nueva lista de objetos con el objeto actualizado
    NewObjectsList = [NewObject | RestObjects],
    % Crea la nueva clase con la lista de objetos actualizada
    NewClass = class(ClassName, Mother, Attrs, Rel, NewObjectsList),
    % Reemplaza la clase antigua por la nueva clase en la base de conocimientos
    select(class(ClassName, Mother, Attrs, Rel, Objects), KB, NewClass, NewKB).
