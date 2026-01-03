# Simplification Cascades

Sometimes one insight eliminates 10 things. Look for the unifying principle that makes multiple components unnecessary.

## Core Principle
**"Everything is a special case of..." collapses complexity dramatically.**

## The Pattern
Look for:
- Multiple implementations of similar concepts.
- Growing lists of "special case" handlers.
- Complex rules with many exceptions.

Ask: **"What if they're all the same thing underneath?"**

## Common Cascades
- **Stream Abstraction**: Treating batch, real-time, and file data all as "streams" eliminates custom handlers for each source.
- **Resource Governance**: Treating session limits, rate limits, and connection pools all as "resource limits" allows for one unified governor.
- **Immutability**: Treating everything as immutable data + transformations eliminates locking and cache invalidation logic.

## The Process
1. **List variations**: What is being implemented multiple ways?
2. **Find the essence**: What is fundamentally the same underneath all these cases?
3. **Extract abstraction**: Define the domain-independent pattern.
4. **Test it**: Do all previous cases fit cleanly into this new model?
5. **Measure the cascade**: How many files, lines, or systems can we now delete?

**One powerful abstraction is better than ten clever hacks. Aim for 10x wins, not 10% improvements.**
