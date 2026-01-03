# Inversion Exercise

Flip every assumption and see what still works. Sometimes the opposite reveals the truth.

## Core Principle
**Inversion exposes hidden assumptions and reveals alternative approaches that are often ignored.**

## The Process
1. **List core assumptions**: What "must" be true for this problem or solution?
2. **Invert each systematically**: "What if the exact opposite were true?"
3. **Explore implications**: What would we have to do differently if the inverted assumption were the reality?
4. **Find valid inversions**: Which of these "opposites" actually provide a better or more resilient path?

## Examples of Inversions
- **Normal**: Pull data when needed. **Inverted**: Push data before needed. (Reveals: Prefetching/Eager loading).
- **Normal**: Optimize for the common case. **Inverted**: Optimize for the worst case. (Reveals: Resilience patterns).
- **Normal**: Cache to reduce latency. **Inverted**: Add latency to enable caching. (Reveals: Debouncing patterns).

## When to Use
- You feel there is "only one way" to do something.
- You are forcing a solution that feels "wrong" or overly complex.
- You hear people say, "This is just how it's done."

**Not all inversions work, but valid ones reveal context-dependence and can lead to the actual answer.**
