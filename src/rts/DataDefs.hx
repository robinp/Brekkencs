package rts;

import util.ValueClass;

typedef TypeName = String;
typedef FieldName = String;

typedef DataDefs = Map<TypeName, DataDef>;

class DataDef implements MutableClass {
  var name: TypeName;
  var fields: FieldDefs;
}

// Eventually type, etc.
typedef FieldDefs = Map<FieldName, Bool>;

function emptyDataDefs(): DataDefs {
  return new Map();
}
