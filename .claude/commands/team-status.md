# Team Status - Multi-Team Development Coordination

Monitor team development progress, identify bottlenecks, and coordinate between teams.

## Usage
```
@team-status [scope]
```

## Scopes
- **all** - Complete multi-team status overview (default)
- **velocity** - Team velocity and performance metrics
- **blockers** - Development blockers and friction points
- **environment** - Development environment health across teams
- **coordination** - Inter-team coordination status
- **performance** - Performance metrics and optimization opportunities

## Team Monitoring
- **ALPHA** - Core Features (Jobs, Locals, Authentication)
- **BETA** - Development Tooling Support (current team)
- **GAMMA** - UI/UX & Electrical Components
- **DELTA** - Infrastructure & Performance

## Features
- Real-time development velocity tracking
- Automated bottleneck detection
- Cross-team dependency monitoring  
- Performance regression alerts
- Environment health validation
- CI/CD pipeline status

## Examples
```bash
@team-status                  # Full multi-team overview
@team-status velocity         # Team performance metrics
@team-status blockers         # Current development blockers
@team-status environment      # Environment health check
```

Provides actionable insights for sprint coordination and team optimization.
