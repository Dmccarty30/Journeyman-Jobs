# Quick Development - One-Command Setup

Instantly setup and start development with optimized configuration.

## Usage
```
@quick-dev [mode]
```

## Modes
- **start** - Quick setup and development start (default)
- **clean** - Clean rebuild and start
- **test** - Setup with test environment
- **emulator** - Start with Firebase emulators only
- **performance** - Development with performance monitoring

## Features
- Automated dependency installation
- Firebase emulator startup
- Hot reload optimization
- Error recovery and retry logic
- Development environment validation
- Intelligent caching

## Examples
```bash
@quick-dev                    # Standard quick start
@quick-dev clean             # Clean setup and start
@quick-dev test              # Development with testing focus
@quick-dev performance       # Performance-optimized development
```

Reduces development startup from 10+ minutes to under 2 minutes.
