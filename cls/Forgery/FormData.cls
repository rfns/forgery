Class Forgery.FormData Extends (%RegisteredObject, Forgery.IFormData)
{

/// An in-memory multiDimensional containing the indexed data to be sent.
Property Data As %DynamicArray [ Private ];

/// Appends the data to the matching key.
Method Append(key As %String, value As %Any)
{
  set entry = {
    "name": (key),
    "value": (value)
  }

  do ..Data.%Push(entry)
}

/// Exposes the current indexed data to consumers.
Method GetEntryIterator() As Forgery.Internal.FormDataEntryIterator
{
  return ##class(Forgery.Internal.FormDataEntryIterator).%New(..Data)
}

}
