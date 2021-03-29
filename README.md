<h1 align="center"><a>Simulacrum.jl</a></h1>

This package uses hypergraphs (implemented via [HyperGraphs.jl](https://github.com/lpmdiaz/HyperGraphs.jl)) to construct symbolic models and simulate their behaviour. More specifically, symbolic variables (implemented via [Symbolics.jl](https://github.com/JuliaSymbolics/Symbolics.jl/tree/master/src)) are put on vertices of a hypergraph, and hyperedges thus describe relationships between variables. This allows to represent dynamical systems as sets of symbolic variables and how they are interacting.

In this sense, hypergraphs provide a _logic_ (the model), and this package provides _dynamics_ i.e. implements ways to interpret the same logic in different ways, resulting in the _simulation_ of the model. This is in a way very similar to [ModelingToolkit.jl](https://github.com/SciML/ModelingToolkit.jl), but here the logic is explicitly exposed as a hypergraph; this allows to interact with models using the language of graph theory, and may provide new ways of studying dymamical systems.

The package description is a quote from Simulations by Jean Baudrillard (which can be found on page 3 of the 1983 Semiotext(e) edition).

## Aims

Using hypergraphs as a backbone, this package aims to provide a language that allows to construct and interact with models easily. On a basic level, this means it is very easy to define components, or submodels, and to then assemble them (by connecting them with hyperedges) to build larger models. Using this language, one may for instance write code that automatically generates models (using the hypergraph manipulation functions defined in HyperGraphs.jl).

Additionally, a benefit of separating logic (the model) and dynamics is that the same model may be interpreted in different ways. Concretely, this means that different simulation approaches can be seen simply as different interpretations of the same underlying logic, and so the same model may be simulated using ODEs, SDEs, exact stochastic simulations, etc., without ever having to modify it. This also synergises with using hypergraphs to represent models: because hypergraphs may be used as a common language to represent different modelling formalisms, it should be possible to connect models that are in nature different, and to then switch between simulation approaches in the same breath.

## Some notes on the code

Things will probably change a lot -- for instance, the syntax will follow that of Symbolics.jl which is relatively recent and so may change in the future...

### General

My current interest is in biochemical dynamical systems; most functions exported here are thus defined on  the `ChemicalHyperGraph` type from HyperGraphs.jl, meaning that they are highly specific. However the approach I am trying to develop here is general enough that it should be applicable to any (hyper)graph (and future versions of this code will hopefully allow this).

This package is connected to ModelingToolkit.jl to allow sending symbolic models on hypergraphs to differential equations solvers (which also allows to pick up some code optimisation on the way, courtesy of ModelingToolkit.jl).

### Symbolic types

Currently, functions work on hypergraphs of type `Num` (via Symbolics.jl) i.e. on `ChemicalHyperGraph{Num}` types.

This package also exports a `SymTypes` type that is a union of `Num` and `Symbolic` and some functions are written at that level.

Note that equations passed to an `ODESystem` and other `AbstractSystem` need to be sent through the internal `get_value` helper (this is because ModelingToolkit.jl needs its symbolic types to be `Term` and not `Num`).

I am not sure if this is the best approach but it does seem to work for now... It may however change in the future.

#### Warning when precompiling

This is caused by doing `Base.:(==)(x::Num, y::Num) = x === y`. Without this however, the following fails:
```julia
using Symbolics
@variables x
x == x # returns "x == x"
x in [x] # errors
```
And this needs to work in order to properly use functions from HyperGraphs.jl... This is probably a poor solution though.

### Exported functions

Functions should be used with caution (especially those defined in `connections.jl`) as this is very much a work in progress and there may be undesirable behaviours. For instance, when using a hyperedge as a template when connecting vertices, the length of all fields in the template hyperedge must match that of all fields in the to-be-created hyperedges, otherwise some fields will have incorrect lengths...

## Notes on the package title and description

The ideas behind this package came together before reading Baudrillard's Simulations, but I thought it was appropriate to use some of it to describe what I am trying to do here.

Baudrillard is highly critical of simulations because (according to him) they create a world where all logic is internally generated and as such is always already out of touch with the 'real' world. Reading the book, I thought it would be tongue-in-cheek to use these very negative ideas to describe this package (and so to use them in a positive way).

But they are also very appropriate to describe the aims of this package: 'combinatory models' is highly relevant because an aim is to use composition to connect models together; 'hyperspace without atmosphere' is very useful to emphasise the fact that models are only models, and that for a model to be useful it has to be connected to reality somehow; and on page 153 Baudrillard tells us that simulation is ‘the operation of the code’ -- the code in question is actually the genetic code, but it works well in this context too!