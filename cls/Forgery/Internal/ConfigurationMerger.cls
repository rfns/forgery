/// Utility class used for merging multiple plain configuration-like objects.
/// 
/// The first object takes precedence over the next ones.
/// This gives the caller control over what properties should remain in the final result.
Class Forgery.Internal.ConfigurationMerger Extends %RegisteredObject
{

/// Merges n+1 objects into n and returns an aggregated result.
ClassMethod Merge(configurations... As %DynamicObject) As %DynamicObject
{
  #dim result As %DynamicObject

  set result = {}

  for i=1:1:configurations {
    set iterator = configurations(i).%GetIterator()
    while iterator.%GetNext(.property, .value) {
      set target = $property(result, property)
      if $isobject(value) && value.%IsA("%DynamicObject") && $isobject(target) {
        set isSameSize = (target.%Size() = value.%Size())
        set hasSameProperty = $property(target, property) = $property(value, property)
        if '(isSameSize && hasSameProperty) {
          set $property(result, property) = ..Merge(target, value)
        }
      } elseif 'result.%IsDefined(property) {
        set $property(result, property) = value
      }
    }
  }
  return result
}

}
