# 1. Record architecture decisions

Date: 2026-05-22

## Status
Accepted

## Context
The repository now spans multiple deployable services, a Flutter client, containerized environments, and CI/CD workflows. Important architecture and infrastructure choices need a durable record so future changes can explain why a direction was chosen instead of forcing contributors to infer intent from code or git history alone.

## Decision
We will record significant architecture and infrastructure decisions as individual ADR files under `docs/adr/`.

Each ADR must use the repository template, include context, decision, consequences, alternatives, and references, and remain append-only after acceptance. Superseding changes must create a new ADR instead of rewriting history.

## Consequences
### Positive
- Decisions about infrastructure, deployment, security, and service boundaries stay discoverable.
- Future contributors can understand why a change exists before extending or replacing it.
- Reviews can point to accepted decisions instead of re-litigating the same tradeoffs.

### Negative
- Contributors must spend a small amount of extra time writing ADRs for meaningful decisions.
- Some decisions may need follow-up ADRs when constraints change.

### Neutral
- ADRs document decisions; they do not replace implementation docs, runbooks, or API contracts.

## Alternatives considered
- Rely on commit history alone — rejected because commit logs are optimized for change tracking, not long-lived architectural rationale.
- Capture decisions in a single evolving design doc — rejected because individual ADRs are easier to reference, supersede, and review.

## References
- `docs/adr/template.md`
- `docs/INDEX.md`
