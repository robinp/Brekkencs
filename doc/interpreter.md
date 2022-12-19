# Interpreter

## Querying entities

### Context

Roadmap for level of sophistication of entity query. Note, this should be
transparent for the user, and is more performance optimization. But premature
optimization is the sqrt(forall x. evil(x)), so let's just jot thoughts instead
implementing.


### Phase 1: naive query

Querying naively loops through all entities. Failing query control filters, or
accesses to unavailable components leads to cutting the entity. The ambiguity of
intention around undefined access (cut? Add with defaults?) is slightly uncanny,
but well (not that further phases help this point).


### Phase 1b: interpreted query with hints

A JIT-like approach to queries: Executing queries would start out naively, but
the runtime would leave hints to the query engine: A hint could include the
shape of the condition checked, optionally along with sample values used in it
(hm, well that is the AST part + context, right?), and maybe the boolean result
of evaluating the condition (is that any helpful in determining which queries
to optimize more? Maybe not).

Then the query engine can build specialized indices that can serve eids with
those criteria faster.

This might give us quite some leeway until the rest of phases is needed (if
ever).


#### Static filter approach

For start, the hinting could take into account just the static
components/fields evaluated. That saves the runtime from needing to do all kind
of peek-ahead and complexity.

Though, it only works as long there aren't any branching paths with different
conditions. Or we could make semantics force uniform conditions on different
branches.. but that would be too strict. Well, one way is to just don't do
query optimization for the conditions inside branches - generic optimizations
could still prefilter. The other is to maintain some separate path-based
indices. But let's rather see some usecases. (See Phase 4 notes).

Though, this component-based static filter is more about looking forward to
know that that is the condition to be used, rather than creating indices (since
we are likely to have the component-to-entity index around in the RTS anyway).


#### Dynamic approcah

Some runtime magic to look forward for the condition part, execute the query
in the face of that (and maybe disable that part of the condition, given it
would be always true anyway).

See Phase 3 notes.


### Phase 2: analyzed component usage

Analyze AST upfront on which components are used/requested, create some upfront
query that fetches the right entity set in a more optimal way (like intersecting
sets or whatever).

Note: this might not play well (or be complicated) if interpreting a system can
have immediately-visible side-effects around component (or entity) creation. But
let's try to get away with not having those immediate sideeffects to begin with,
to spare hassle. Or in the case when they are used, we would just disable
analyzed query? Etc.

Note: We might be able to implement "analyzing" by just running a dummy interpreting
round, that runs over the AST and performs query hinting without specific
values?


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


## Drawing

There are basically two approaches to drawing: a more imperative, where the
program itself controls drawing order, and draw calls are executed on the spot;
and a more declarative, where the program just asks for a draw, but they happen
independently ordered.

The first one is less surprizing maybe, while the second lets for better
batching on various draw-states (color, texture etc). But for Brekkencs, at
least for now, we don't need that sophistication (and well, the program can
itself be written to be aware of these orderings if needed... then the
interpreter, or even some jit, can make the decision to change state or not).

TODO: probably should remove effectful statements alltogether, and rather
use components. Native listeners should then act on entities with specific
components (and take ordering into account based on other components, etc).
This is more flexible, also leads to a smaller language.
