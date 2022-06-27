# Interpreter

## Querying entities

Roadmap for level of sophistication of entity query. Note, this should be
transparent for the user, and is more performance optimization. But premature
optimization is the sqrt(forall x. evil(x)), so let's just jot thoughts instead
implementing.

### Phase 1: naive query

Querying naively loops through all entities. Failing query control filters, or
accesses to unavailable components leads to cutting the entity. The ambiguity of
intention around undefined access (cut? Add with defaults?) is slightly uncanny,
but well (not that further phases help this point).

### Phase 2: analyzed component usage

Analyze AST upfront on which components are used/requested, create some upfront
query that fetches the right entity set in a more optimal way (like intersecting
sets or whatever).

Note: this might not play well (or be complicated) if interpreting a system can
have immediately-visible side-effects around component (or entity) creation. But
let's try to get away with not having those immediate sideeffects to begin with,
to spare hassle. Or in the case when they are used, we would just disable
analyzed query? Etc.

### Phase 3: analyzed filter expressions

Based on the filter expressions, we might be able to utilize more advanced
indices under the hood.

For example, when we see entities are checked on intersecting bounds, we can
automatically create some broadphase (spatial query) structure to support these
efficiently.

### Phase 4: control paths, or just random notes

Not sure if a phase or not - but what should happen once we have some control
structures, and different paths taken in those would access different
components? Fall back to naive querying, at least on those subpaths? Prepare
multiple indices?

Note: ultimately multiple paths could be factored into a multitude of systems,
with different cuts (a choice in the original system becomes a checked cut in
the generated ones). We should probably not impose the task of factoring to
systems on users (unless they want to). So we should treat it somehow (note:
factoring ourselves under the hood into more straight, pregenerated index +
choice-less execution path-ed systems might come with performance benefits...
just wondering aloud, evils and all).
