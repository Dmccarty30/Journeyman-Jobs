# Scale Game

Test your approach at extreme scales to find what breaks and what surprisingly survives.

## Core Principle
**Extremes expose fundamental truths hidden at normal scales.**

## The Process
1. **Pick dimension**: What could vary extremely? (Volume, Speed, Users, Duration).
2. **Test minimum**: What if this was 1000x smaller, faster, or fewer?
3. **Test maximum**: What if this was 1000x bigger, slower, or more?
4. **Note what breaks**: Where do the hard limits appear?
5. **Note what survives**: What logic or pattern is fundamentally sound regardless of scale?

## Scale Dimensions
- **Volume**: 1 item vs. 1 Billion items. (Reveals algorithmic complexity).
- **Speed**: Instant vs. 1 Year. (Reveals caching and async requirements).
- **Users**: 1 user vs. 1 Billion users. (Reveals concurrency and resource contention).
- **Duration**: Milliseconds vs. Years. (Reveals memory leaks and state growth).

## When to Use
- "It works in dev" but you're unsure about production.
- You don't know where the actual limits of your system are.
- You're validating a new architecture for potentially high volumes.

**What works at one scale often fails at another. Test both directions to validate your architecture early.**
